class AddNamesIndexes < ActiveRecord::Migration[7.1]
  def up
    add_column :recipes, :search_vector, :tsvector
    add_index  :recipes, :search_vector, using: :gin

    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_recipes_search_vector() RETURNS trigger AS $$
      DECLARE
        ingredients_singulars TEXT;
      BEGIN
        SELECT STRING_AGG(ingredients.names->>'singular', ' ')
        INTO ingredients_singulars
        FROM ingredients
        INNER JOIN recipe_ingredients
        ON recipe_ingredients.recipe_id = NEW.id
        AND recipe_ingredients.ingredient_id = ingredients.id;
      
        NEW.search_vector := to_tsvector('pg_catalog.french', NEW.name || ' ' || ingredients_singulars);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER recipes_search_vector_update
      BEFORE INSERT OR UPDATE ON recipes
      FOR EACH ROW EXECUTE FUNCTION update_recipes_search_vector();
    SQL

    execute <<-SQL
      UPDATE recipes R
      SET search_vector = to_tsvector(
        'pg_catalog.french',
        R.name || ' ' || (
          SELECT STRING_AGG(I.names->>'singular', ' ')
          FROM ingredients I
          INNER JOIN recipe_ingredients RI
          ON RI.ingredient_id = I.id
          AND RI.recipe_id = R.id
        )
      );
    SQL

    add_column :ingredients, :search_vector, :tsvector
    add_index  :ingredients, :search_vector, using: :gin

    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_ingredients_search_vector() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector := to_tsvector('pg_catalog.french', NEW.names->>'singular');
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER ingredients_search_vector_update
      BEFORE INSERT OR UPDATE ON ingredients
      FOR EACH ROW EXECUTE FUNCTION update_ingredients_search_vector();
    SQL

    execute <<-SQL
      UPDATE ingredients
      SET search_vector = to_tsvector('pg_catalog.french', names->>'singular')
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS recipes_search_vector_update ON recipes;
      DROP TRIGGER IF EXISTS ingredients_search_vector_update ON ingredients;
    SQL

    execute <<-SQL
      DROP FUNCTION IF EXISTS update_recipes_search_vector();
      DROP FUNCTION IF EXISTS update_ingredients_search_vector();
    SQL

    remove_index :recipes, :search_vector
    remove_index :ingredients, :search_vector

    remove_column :recipes, :search_vector
    remove_column :ingredients, :search_vector
  end
end
