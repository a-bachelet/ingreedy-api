# frozen_string_literal: true

# == Schema Information
#
# Table name: recipe_ingredients
#
#  id            :bigint           not null, primary key
#  quantity      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#  recipe_id     :bigint           not null
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
require 'rails_helper'

RSpec.describe RecipeIngredient do
  subject { build(:recipe_ingredient) }

  it { is_expected.to validate_presence_of(:quantity) }

  it { is_expected.to belong_to(:recipe) }
  it { is_expected.to belong_to(:ingredient) }
  it { is_expected.to belong_to(:unit).optional }
end
