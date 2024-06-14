# frozen_string_literal: true

class UpdateIngredientsNameToNames < ActiveRecord::Migration[7.1]
  def up
    add_column :ingredients, :names, :jsonb, default: { singular: '', plural: '' }.to_s

    Ingredient.find_each { _1.update(names: { singular: _1.name, plural: '' }) }

    change_column_null :ingredients, :names, false

    remove_column :ingredients, :name
  end

  def down
    add_column :ingredients, :name, :string

    Ingredient.find_each { _1.update(name: _1.names['singular']) }

    change_column_null :ingredients, :name, false

    remove_column :ingredients, :names
  end
end
