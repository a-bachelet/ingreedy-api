# frozen_string_literal: true

class AddDataToRecipes < ActiveRecord::Migration[7.1]
  def change # rubocop:disable Metrics/MethodLength
    create_enum :recipe_budget, %w[cheap affordable medium high very_high luxurious]

    change_column_null :recipes, :name, false

    change_table :recipes, bulk: true do |t|
      t.string :slug, null: false, default: ''
      t.decimal :rate, null: false, default: 0
      t.enum :budget, enum_type: :recipe_budget, null: false, default: :cheap
      t.integer :prep_time, null: false, default: 0
      t.integer :cook_time, null: false, default: 0
      t.integer :total_time, null: false, default: 0
      t.string :image_url, null: false, default: ''
    end

    add_index :recipes, :slug, unique: true
  end
end
