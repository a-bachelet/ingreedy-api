# frozen_string_literal: true

# == Schema Information
#
# Table name: recipe_ingredients
#
#  quantity      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null, primary key
#  recipe_id     :bigint           not null, primary key
#  unit_id       :bigint
#
# Indexes
#
#  index_recipe_ingredients_on_ingredient_id  (ingredient_id)
#  index_recipe_ingredients_on_recipe_id      (recipe_id)
#  index_recipe_ingredients_on_unit_id        (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (recipe_id => recipes.id)
#  fk_rails_...  (unit_id => units.id)
#
class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  belongs_to :unit, optional: true

  self.primary_key = [:recipe_id, :ingredient_id]
end
