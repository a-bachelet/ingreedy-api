# frozen_string_literal: true

class EnhanceRecipes < ActiveRecord::Migration[7.1]
  def change
    create_enum :recipe_difficulty, %w[very_easy easy medium difficult]

    change_table :recipes, bulk: true do |t|
      t.string :author_name, null: false, default: 'Ingreedy'
      t.string :author_tip
      t.integer :people_quantity, null: false, default: 1
      t.enum :difficulty, enum_type: :recipe_difficulty, null: false, default: :medium
    end
  end
end
