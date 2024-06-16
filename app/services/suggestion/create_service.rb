class Suggestion
  class CreateService
    class << self
      delegate :call, :to => :new
    end

    def call(params)
      suggestion = nil

      ActiveRecord::Base.transaction do
        ingredients = parse_ingredients(params[:ingredients] || default_ingredients)
        perfect_match_only = ActiveModel::Type::Boolean.new.cast(params[:perfect_match_only])
        suggestion = Suggestion.create(ingredients:, perfect_match_only:)
        recipes = search_suggestable_recipes(suggestion)
        suggestion.update(recipes:)
      end

      suggestion
    end

    private

    def initialize; end

    def parse_ingredients(ingredients)
      ingredients.map do |ingredient|
        { id: ingredient['id'], quantity: ingredient['quantity'], unit_id: ingredient['unit_id'] }
      end
    end

    def default_ingredients
      Fridge.first_or_create.fridge_ingredients.map do |fridge_ingredient|
        {
          'id' => fridge_ingredient.ingredient_id,
          'quantity' => fridge_ingredient.quantity,
          'unit_id' => fridge_ingredient.unit_id
        }
      end
    end

    def search_suggestable_recipes(suggestion)
      query = build_suggestable_recipes_query(suggestion)
      ActiveRecord::Base.connection.execute(query).to_a.map do |recipe|
        { id: recipe['id'], name: recipe['name'], score: recipe['score'], perfect: recipe['perfect'] }
      end
    end

    def build_suggestable_recipes_query(suggestion)
      available_ingredients_query = build_available_ingredients_query(suggestion)
      full_perfect_matches_query = build_full_perfect_matches_query
      partial_perfect_matches_query = build_partial_perfect_matches_query
      unit_matches_query = build_unit_matches_query
      ingredient_matches_query = build_ingredient_matches_query

      recipes_query = build_recipes_query(
        suggestion, available_ingredients_query, full_perfect_matches_query,
        partial_perfect_matches_query, unit_matches_query, ingredient_matches_query
      )
    end

    def build_available_ingredients_query(suggestion)
      <<-SQL
        SELECT
          i.id AS ingredient_id,
          i.quantity AS quantity,
          i.unit_id AS unit_id
        FROM
          suggestions,
          jsonb_to_recordset(suggestions.ingredients) AS i(id bigint, quantity INTEGER, unit_id bigint)
        WHERE suggestions.id = #{suggestion.id.to_i}
      SQL
    end

    def build_full_perfect_matches_query
      <<-SQL
        SELECT R.id, COUNT(RI.ingredient_id) AS full_perfect_match_count
        FROM recipes R
        LEFT OUTER JOIN recipe_ingredients RI
          ON R.id = RI.recipe_id
        LEFT OUTER JOIN available_ingredients AI
          ON RI.ingredient_id = AI.ingredient_id
          AND AI.quantity >= RI.quantity
        LEFT OUTER JOIN units U
          ON (U.id = RI.unit_id OR (RI.unit_id IS NULL AND U.names->>'singular' = ''))
          AND (U.id = AI.unit_id OR (AI.unit_id IS NULL AND U.names->>'singular' = ''))
        GROUP BY R.id
        HAVING(COUNT(RI.ingredient_id) = COUNT(AI.ingredient_id))
      SQL
    end

    def build_partial_perfect_matches_query
      <<-SQL
        SELECT R.id, COUNT(RI.ingredient_id) AS partial_perfect_match_count
        FROM recipes R
        JOIN recipe_ingredients RI
          ON R.id = RI.recipe_id
        JOIN available_ingredients AI
          ON RI.ingredient_id = AI.ingredient_id
        JOIN units U
          ON (U.id = RI.unit_id OR (RI.unit_id IS NULL AND U.names->>'singular' = ''))
          AND (U.id = AI.unit_id OR (AI.unit_id IS NULL AND U.names->>'singular' = ''))
        GROUP BY R.id
        HAVING(COUNT(RI.ingredient_id) = COUNT(AI.ingredient_id))
      SQL
    end

    def build_unit_matches_query
      <<-SQL
        SELECT R.id, COUNT(RI.ingredient_id) AS unit_match_count
        FROM recipes R
        JOIN recipe_ingredients RI
          ON R.id = RI.recipe_id
        JOIN available_ingredients AI
          ON RI.ingredient_id = AI.ingredient_id
        JOIN units U
          ON (U.id = RI.unit_id OR (RI.unit_id IS NULL AND U.names->>'singular' = ''))
        AND (U.id = AI.unit_id OR (AI.unit_id IS NULL AND U.names->>'singular' = ''))
        GROUP BY R.id
      SQL
    end

    def build_ingredient_matches_query
      <<-SQL
        SELECT R.id, COUNT(RI.ingredient_id) AS ingredient_match_count
        FROM recipes R
        JOIN recipe_ingredients RI
          ON R.id = RI.recipe_id
        JOIN available_ingredients AI
          ON RI.ingredient_id = AI.ingredient_id
        GROUP BY R.id
      SQL
    end

    def build_recipes_query(
      suggestion, available_ingredients_query, full_perfect_matches_query,
      partial_perfect_matches_query, unit_matches_query, ingredient_matches_query
    )
      <<-SQL
        WITH
          available_ingredients AS (#{available_ingredients_query}),
          full_perfect_matches AS (#{full_perfect_matches_query}),
          partial_perfect_matches AS (#{partial_perfect_matches_query}),
          unit_matches AS (#{unit_matches_query}),
          ingredient_matches AS (#{ingredient_matches_query})

        SELECT 
          R.id, R.name,
          COALESCE(FPM.full_perfect_match_count, 0) AS fpm,
          COALESCE(PPM.partial_perfect_match_count, 0) AS ppm,
          COALESCE(UM.unit_match_count, 0) AS um,
          COALESCE(IM.ingredient_match_count, 0) AS im,
          COUNT(RI.ingredient_id) AS total_ingredients_count,
          (
            COALESCE(FPM.full_perfect_match_count, 0) * 4 +
            COALESCE(PPM.partial_perfect_match_count, 0) * 3 +
            COALESCE(UM.unit_match_count, 0) * 2 +
            COALESCE(IM.ingredient_match_count, 0)
          ) AS score,
          COALESCE(FPM.full_perfect_match_count, 0) > 0 AS perfect
        
        FROM recipes R
        
        LEFT OUTER JOIN recipe_ingredients RI ON RI.recipe_id = R.id
        LEFT OUTER JOIN full_perfect_matches FPM ON FPM.id = R.id
        LEFT OUTER JOIN partial_perfect_matches PPM ON PPM.id = R.id
        LEFT OUTER JOIN unit_matches UM ON UM.id = R.id
        LEFT OUTER JOIN ingredient_matches IM ON IM.id = R.id
        
        WHERE FPM.id IS NOT NULL OR PPM.id IS NOT NULL
        
        #{'AND FPM.full_perfect_match_count > 0' if suggestion.perfect_match_only}
        
        GROUP BY R.id, FPM.full_perfect_match_count, PPM.partial_perfect_match_count, UM.unit_match_count, IM.ingredient_match_count
        
        ORDER BY
          score DESC,
          FPM.full_perfect_match_count,
          PPM.partial_perfect_match_count,
          UM.unit_match_count,
          IM.ingredient_match_count,
          total_ingredients_count,
          R.name
      SQL
    end
  end
end
