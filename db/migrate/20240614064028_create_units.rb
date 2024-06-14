# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :units do |t|
      t.jsonb :names, null: false, default: { singular: '', plural: '' }.to_s

      t.timestamps
    end

    add_reference :fridge_ingredients, :unit, foreign_key: true
    add_reference :recipe_ingredients, :unit, foreign_key: true
  end
end
