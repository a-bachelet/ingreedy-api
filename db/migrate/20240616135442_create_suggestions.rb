class CreateSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :suggestions do |t|
      t.jsonb :ingredients, null:false, default: '[]'
      t.jsonb :recipes, null: false, default: '[]'
      t.boolean :perfect_match_only, null: false, default: false

      t.timestamps
    end
  end
end
