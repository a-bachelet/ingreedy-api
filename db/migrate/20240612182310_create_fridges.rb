# frozen_string_literal: true

class CreateFridges < ActiveRecord::Migration[7.1]
  def change
    create_table :fridges, &:timestamps
  end
end
