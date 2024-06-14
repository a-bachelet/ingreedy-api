class AddDataToRecipes < ActiveRecord::Migration[7.1]
  def change
    create_enum :recipe_budget, %w[cheap affordable medium high very_high luxurious]

    change_column_null :recipes, :name, false

    add_column :recipes, :slug, :string, null: false
    add_column :recipes, :rate, :decimal, null: false, default: 0
    add_column :recipes, :budget, :enum, enum_type: :recipe_budget, null: false, default: :cheap
    add_column :recipes, :prep_time, :integer, null: false, default: 0
    add_column :recipes, :cook_time, :integer, null: false, default: 0
    add_column :recipes, :total_time, :integer, null: false, default: 0
    add_column :recipes, :image_url, :string, null: false

    add_index :recipes, :slug, unique: true
  end
end
