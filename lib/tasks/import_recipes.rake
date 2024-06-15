# frozen_string_literal: true

namespace :recipes do
  desc 'Import recipes from a static JSON file'
  task import: :environment do
    setup_parsing_helpers
    
    unprocessed_recipes = load_recipes_from_json_file

    ignore_duplicates!(unprocessed_recipes)

    total_count = unprocessed_recipes.count
    successes = 0
    failures = 0

    puts "🤖 'Recipes Import Script' starting..."
    puts "🤖 #{total_count} recipes can be imported !"
    puts ''

    unprocessed_recipes.each_with_index do |unprocessed_recipe, index|      
      begin
        puts "🧠 Normalizing recipe '#{index + 1}/#{total_count}'..."
        normalized_recipe = normalize_recipe(unprocessed_recipe)
        puts "✅ Recipe '#{index + 1}/#{total_count}' normalized successfully !"
      rescue StandardError => err
        puts "❌ Error normalizing recipe '#{index + 1}/#{total_count}'. (#{err.class})"
        failures += 1
      end

      unless normalized_recipe
        puts ''
        next
      end

      begin
        puts "🧑‍🍳 Importing recipe '#{index + 1}/#{total_count}'..."
        imported_recipe = import_recipe(normalized_recipe)

        if imported_recipe.errors.any?
          puts "❌ Error importing recipe '#{index + 1}/#{total_count}'. (INVALID )"
          failures += 1
        else
          puts "✅ Recipe '#{index + 1}/#{total_count}' imported successfully !"
          successes += 1
        end
      rescue StandardError => err
        puts "❌ Error importing recipe '#{index + 1}/#{total_count}'. (#{err.class})"
        failures += 1
      end

      puts '' unless index + 1 == total_count
    end

    if failures == 0
      puts "🤖 'Recipes Import Script' finished successfully ! 🍾"
    else
      puts "🤖 'Recipes Import Script' finished with errors... 🔥"
    end

    puts "🏭 #{successes + failures} recipes processed"
    puts "✅ #{successes} recipes succeded"
    puts "❌ #{failures} recipes failed"
  end
end

def setup_parsing_helpers
  @time_regex = /^(?:^|(\d+)j)?(?:^|(\d+)h)?(?:^|(\d+)(?:m|mn|min|))?$/
  
  @raw_keys = %w[rate author_tip name author people_quantity image]
  
  @budgets_matrix = {
    'bon marché' => 'affordable',
    'coût moyen' => 'medium',
    'assez cher' => 'high'
  }
  
  @difficulties_matrix = {
    'très facile' => 'very_easy',
    'facile' => 'easy',
    'niveau moyen' => 'medium',
    'difficile' => 'difficult'
  }
end

def load_recipes_from_json_file
  filename = 'static/recipes-fr.json'
  file = File.read(filename)
  
  recipes = JSON.parse(file)
  
  recipes.reject! do |recipe|
    recipe['image'].nil? || recipe['image']&.empty? ||
    recipe['ingredients'].nil? || recipe['ingredients']&.empty? ||
    !@time_regex.match?(recipe['prep_time'].delete(' ').downcase) ||
    !@time_regex.match?(recipe['cook_time'].delete(' ').downcase) ||
    !@time_regex.match?(recipe['total_time'].delete(' ').downcase)
  end
end

def ignore_duplicates!(unprocessed_recipes)
  unprocessed_recipes.reject! { !!Recipe.find_by(name: _1['name']) }
end

def normalize_recipe(unprocessed_recipe)
  normalized_recipe = {}
  normalize_raw_keys(unprocessed_recipe, normalized_recipe)
  normalize_slug(unprocessed_recipe, normalized_recipe)
  normalize_budget(unprocessed_recipe, normalized_recipe)
  normalize_difficulty(unprocessed_recipe, normalized_recipe)
  normalize_tags(unprocessed_recipe, normalized_recipe)
  normalize_times(unprocessed_recipe, normalized_recipe)
  normalize_ingredients(unprocessed_recipe, normalized_recipe)
  normalized_recipe
end

def normalize_raw_keys(unprocessed_recipe, normalized_recipe)
  @raw_keys.each { |key| normalized_recipe[key.to_sym] = unprocessed_recipe[key] }
  normalized_recipe[:rate] = 2.5 unless normalized_recipe[:rate] && normalized_recipe[:rate] != ''
end

def normalize_slug(unprocessed_recipe, normalized_recipe)
  normalized_recipe[:slug] = slugify(unprocessed_recipe['name'])
end

def normalize_budget(unprocessed_recipe, normalized_recipe)
  normalized_recipe[:budget] = @budgets_matrix[unprocessed_recipe['budget'].downcase]
end

def normalize_difficulty(unprocessed_recipe, normalized_recipe)
  normalized_recipe[:difficulty] = @difficulties_matrix[unprocessed_recipe['difficulty'].downcase]
end

def normalize_tags(unprocessed_recipe, normalized_recipe)
  normalized_recipe[:tags] = unprocessed_recipe['tags'].index_with { slugify(_1) }
end

def normalize_times(unprocessed_recipe, normalized_recipe)
  parsed_prep_time = @time_regex.match(unprocessed_recipe['prep_time'].delete(' ').downcase)[1..3]
  parsed_cook_time = @time_regex.match(unprocessed_recipe['cook_time'].delete(' ').downcase)[1..3]
  parsed_total_time = @time_regex.match(unprocessed_recipe['total_time'].delete(' ').downcase)[1..3]

  prep_time_in_minutes = duration_to_minutes *parsed_prep_time
  cook_time_in_minutes = duration_to_minutes *parsed_cook_time
  total_time_in_minutes = duration_to_minutes *parsed_total_time

  normalized_recipe[:prep_time] = prep_time_in_minutes
  normalized_recipe[:cook_time] = cook_time_in_minutes
  normalized_recipe[:total_time] = total_time_in_minutes
end

def normalize_ingredients(unprocessed_recipe, normalized_recipe)
  ingredients_normalization_result = make_ingredients_usable(unprocessed_recipe['ingredients'].to_s)
  normalized_ingredients = JSON.parse(ingredients_normalization_result.dig('choices', 0, 'message', 'content'))
  normalized_recipe[:ingredients] = normalized_ingredients['ingredients']
end

def import_recipe(normalized_recipe)
  Recipe.create(
    name: normalized_recipe[:name],
    slug: normalized_recipe[:slug],
    rate: normalized_recipe[:rate],
    author_name: normalized_recipe[:author],
    author_tip: normalized_recipe[:author_tip],
    people_quantity: normalized_recipe[:people_quantity],
    budget: normalized_recipe[:budget],
    difficulty: normalized_recipe[:difficulty],
    image_url: normalized_recipe[:image],
    prep_time: normalized_recipe[:prep_time],
    cook_time: normalized_recipe[:cook_time],
    total_time: normalized_recipe[:total_time],
    tags: find_or_create_tags(normalized_recipe[:tags]),
    recipe_ingredients: find_or_create_recipe_ingredients(normalized_recipe[:ingredients])
  )
end

def find_or_create_tags(normalized_tags)
  normalized_tags.map do |tag_name, tag_slug|
    Tag.find_or_create_by(name: tag_name, slug: tag_slug)
  end
end

def find_or_create_recipe_ingredients(normalized_ingredients)
  normalized_ingredients.map do |ingredient|
    ingredient = find_or_create_ingredient(ingredient['name'])
    unit = find_or_create_unit(ingredient['unit'])
    
    RecipeIngredient.new(ingredient:, quantity: ingredient['quantity'], unit:)
  end
end

def find_or_create_ingredient(normalized_ingredient)
  Ingredient.find_or_create_by(names: normalized_ingredient)
end

def find_or_create_unit(normalized_unit)
  Unit.find_or_create_by(names: normalized_unit)
end

def slugify(str)
  str.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-|-\z/, '')
end

def duration_to_minutes(days, hours, minutes)
  days_minutes = (days.to_i || 0) * 24 * 60
  hours_minutes = (hours.to_i || 0) * 60
  minutes = minutes.to_i || 0

  days_minutes + hours_minutes + minutes
end

def make_ingredients_usable(message)
  system_prompt = <<-STR
    You are a JSON parser, you identify as a JSON parser.
    Your role is to help us to extract ingredients informations from food recipes ingredients list.
    I will give you JSON objects that represent food recipes ingredients list.
    
    For example :
    [
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
    ]
    
    For each ingredient of the list, i want three informations : the name, the quantity, and the unit.
    Every ingredient will be exposed in french.
    
    I want you to always give me results with form of { name: { singular: string, plural: string }, quantity: integer, unit: { singular: string, plural: string } }
    
    Every plural form of ingredient name or ingredient unit must be the french plural form of it.
  STR

  messages = [
    { role: :system, content: system_prompt},
    { role: :user, content: message }
  ]
  
  openai = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_KEY'))
  
  parameters = {
    model: 'gpt-3.5-turbo',
    messages:,
    response_format:{ type: :json_object }
  }

  openai.chat(parameters:)
end