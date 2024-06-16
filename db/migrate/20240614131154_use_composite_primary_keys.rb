# frozen_string_literal: true

class UseCompositePrimaryKeys < ActiveRecord::Migration[7.1]
  # def change
  # end

  def up # rubocop:disable Metrics/MethodLength
    change_table :fridge_ingredients do |t|
      t.remove :id
      execute 'ALTER TABLE fridge_ingredients ADD PRIMARY KEY(fridge_id, ingredient_id);'
    end

    change_table :recipe_ingredients do |t|
      t.remove :id
      execute 'ALTER TABLE recipe_ingredients ADD PRIMARY KEY(recipe_id, ingredient_id);'
    end

    change_table :recipe_tags do |t|
      t.remove :id
      execute 'ALTER TABLE recipe_tags ADD PRIMARY KEY(recipe_id, tag_id);'
    end
  end

  def down # rubocop:disable Metrics/MethodLength
    execute('alter table fridge_ingredients drop constraint fridge_ingredients_pkey;')
    execute('alter table recipe_ingredients drop constraint recipe_ingredients_pkey;')
    execute('alter table recipe_tags drop constraint recipe_tags_pkey;')

    change_table :fridge_ingredients do |t|
      t.bigserial :id
    end
    change_table :recipe_ingredients do |t|
      t.bigserial :id
    end
    change_table :recipe_tags do |t|
      t.bigserial :id
    end

    execute 'ALTER TABLE fridge_ingredients ADD PRIMARY KEY(id);'
    execute 'ALTER TABLE recipe_ingredients ADD PRIMARY KEY(id);'
    execute 'ALTER TABLE recipe_tags ADD PRIMARY KEY(id);'
  end
end
