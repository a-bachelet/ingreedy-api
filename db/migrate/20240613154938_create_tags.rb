# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
