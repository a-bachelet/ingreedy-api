# frozen_string_literal: true

class CreateFridgeIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :fridge_ingredients do |t|
      t.references :fridge, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
