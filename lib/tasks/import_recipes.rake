# frozen_string_literal: true

namespace :recipes do
  desc 'Import recipes from a static JSON file'
  task import: :environment do
    recipes = fetch_recipes

    total_count = recipes.count

    processed = 0
    success = 0
    failures = 0

    recipes.each_with_index do |recipe, idx|
      processed += 1

      tell_about_normalization(idx, total_count)
      normalized_recipe = normalize_recipe(recipe)
      tell_about_normalization_success(normalized_recipe, idx, total_count)
      puts ''

      next unless normalized_recipe

      tell_about_import(idx, total_count)
      imported_recipe = import_recipe(normalized_recipe)
      tell_about_import_success(imported_recipe, idx, total_count) && failures += 1
      puts ''
      puts '--------'
      puts ''
    end

    tell_about_operation(total_count, processed, success, failures)
  end
end

def openai
  @openai ||= OpenAI::Client.new(access_token: ENV.fetch('OPENAI_KEY'))
end

def system_prompt
  <<-STR
    You are a JSON parser, you identify as a JSON parser.

    Your role is to help us to extract some informations
    from food recipes formatted in JSON.

    I will give you JSON objects in the form of recipes data,
    for example :

    {
      "rate": "5",
      "author_tip": "",
      "budget": "bon marché",
      "prep_time": "15 min",
      "ingredients": [
        "600g de pâte à crêpe",
        "1/2 orange",
        "1/2 banane",
        "1/2 poire pochée",
        "1poignée de framboises",
        "75g de Nutella®",
        "1poignée de noisettes torréfiées",
        "1/2poignée d'amandes concassées",
        "1cuillère à café d'orange confites en dés",
        "2cuillères à café de noix de coco rapée",
        "1/2poignée de pistache concassées",
        "2cuillères à soupe d'amandes effilées"
      ],
      "name": "6 ingrédients que l’on peut ajouter sur une crêpe au Nutella®",
      "author": "Nutella",
      "difficulty": "très facile",
      "people_quantity": "6",
      "cook_time": "10 min",
      "tags": [
        "Crêpe",
        "Crêpes sucrées",
        "Végétarien",
        "Dessert"
      ],
      "total_time": "25 min",
      "image": "https://assets.afcdn.com/recipe/20171006/72810_w420h344c1cx2544cy1696cxt0cyt0cxb5088cyb3392.jpg",
      "nb_comments": "1"
    }

    What i want from you is to normalize those JSON recipes data in the same format each time,
    avoiding duplicated informations, extracting more data from sentences.

    For example, for ingredients, here, i want :

    {
      ...
      ingredients: [
        { name: { singular: 'pâte à crêpe', plural: 'pâte à crêpe' }, quantity: 600, unit: { singular: 'g', plural: 'g' } },
        { name: { singular: 'noisette torréfiée', plural: 'noisettes torréfiées' }, quantity: 1, unit: { singular: 'poignée', plural: 'poignées' } },
        { name: { singular: 'noix de coco rapée', plural: 'noix de coco rapées' }, quantity: '2', unit: { singular: 'cuillère à café', plural: 'cuillères à café' } }
        ...
      ]
      ...
    }

    All slugs must be in kebab case !

    Make sure ingredient names and units have both singular and plural form !
  STR
end

def system_message
  { role: :system, content: system_prompt }
end

def system_function # rubocop:disable Metrics/MethodLength
  {
    type: 'function',
    function: {
      name: 'parse_recipe_json_data',
      description: 'Parses a recipe json data',
      parameters: {
        type: :object,
        properties: {
          name: {
            type: :string,
            description: 'The recipe name'
          },
          slug: {
            type: :string,
            description: 'The slugified recipe name in kebab case'
          },
          rate: {
            type: :number,
            description: 'The recipe rate from 0 to 5'
          },
          budget: {
            type: :string,
            description: 'The recipe budget estimation',
            enum: %w[cheap affordable medium high very_high luxurious]
          },
          prep_time: {
            type: :integer,
            description: 'The recipe initial preparation time in minutes'
          },
          cook_time: {
            type: :integer,
            description: 'The recipe cooking time in minutes'
          },
          total_time: {
            type: :integer,
            description: 'Addition of prep_time and cook_time'
          },
          image_url: {
            type: :string,
            description: 'URL of recipe image'
          },
          ingredients: {
            type: :array,
            description: 'The recipe ingredients list',
            items: {
              type: :object,
              properties: {
                name: {
                  type: :object,
                  properties: {
                    singular: { type: :string },
                    plural: { type: :string }
                  }
                },
                quantity: { type: :integer },
                unit: {
                  type: :object,
                  properties: {
                    singular: { type: :string },
                    plural: { type: :string }
                  }
                }
              }
            }
          },
          tags: {
            type: :array,
            description: 'The recipe tags list',
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                slug: { type: :string }
              }
            }
          }
        },
        required: %w[
          name slug rate budget prep_time cook_time
          total_time image ingredients tags
        ]
      }
    }
  }
end

def fetch_recipes
  JSON.parse(File.read('static/recipes-fr.json')).reject { _1['image'].empty? }
end

def prompt_parameters(message)
  {
    model: 'gpt-3.5-turbo',
    messages: [system_message, message],
    tools: [system_function],
    tool_choice: :required
  }
end

def normalize_recipe(recipe)
  message = { role: :user, content: recipe.to_s }

  begin
    openai_result = openai.chat(parameters: prompt_parameters(message))
    result = openai_result.dig('choices', 0, 'message', 'tool_calls', 0, 'function', 'arguments')
    JSON.parse(result)
  rescue Faraday::Error, JSON::ParserError
    nil
  end
end

def import_recipe(normalized_recipe)
  recipe = find_or_initialize_recipe(normalized_recipe)

  return recipe unless recipe.new_record?

  set_recipe_attributes(recipe, normalized_recipe)

  recipe.save
  recipe
end

def find_or_initialize_recipe(normalized_recipe)
  Recipe.find_or_initialize_by(slug: normalized_recipe['slug'])
end

def set_recipe_attributes(recipe, normalized_recipe)
  attributes = %w[name rate budget prep_time cook_time total_time image_url].index_with { normalized_recipe[_1] }

  recipe.assign_attributes(attributes)
  recipe.recipe_ingredients = build_recipe_ingredients(normalized_recipe)
  recipe.recipe_tags = build_recipe_tags(normalized_recipe)
end

def build_recipe_ingredients(normalized_recipe)
  normalized_ingredients = normalized_recipe['ingredients'] || []

  return [] if normalized_ingredients.empty?

  normalized_ingredients.map do |normalized_ingredient|
    RecipeIngredient.new(
      unit: Unit.find_or_initialize_by(names: normalized_ingredient['unit']),
      ingredient: Ingredient.find_or_initialize_by(names: normalized_ingredient['name']),
      quantity: normalized_ingredient['quantity']
    )
  end.select(&:ingredient)
end

def build_recipe_tags(normalized_recipe)
  normalized_tags = normalized_recipe['tags'] || []

  return [] if normalized_tags.empty?

  normalized_tags.map do |normalized_tag|
    RecipeTag.new(
      tag: Tag.find_or_initialize_by(slug: normalized_tag['slug']) { _1.name = normalized_tag['name'] }
    )
  end
end

def tell_about_normalization(index, total)
  puts "🧠 Normalizing recipe '#{index + 1}/#{total}'..."
end

def tell_about_normalization_success(normalization, index, total)
  success = "✅ Recipe '#{index + 1}/#{total}' normalized successfully !"
  failure = "❌ Error normalizing recipe '#{index + 1}/#{total}'."

  puts normalization ? success : failure

  !!normalization
end

def tell_about_import(index, total)
  puts "🧑‍🍳 Importing recipe '#{index + 1}/#{total}'..."
end

def tell_about_import_success(import, index, total)
  success = "✅ Recipe '#{index + 1}/#{total}' imported successfully !"
  failure = "❌ Error importing recipe '#{index + 1}/#{total}'."

  puts import ? success : failure

  !!import
end

def tell_about_operation(total, processed, success, failures)
  puts "Process #{processed}/#{total} recipes 💪"
  puts "#{success} Success ✅"
  puts "#{failures} Failures ❌"
end
