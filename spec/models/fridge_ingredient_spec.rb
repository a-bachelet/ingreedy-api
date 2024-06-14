# frozen_string_literal: true

# == Schema Information
#
# Table name: fridge_ingredients
#
#  id            :bigint           not null, primary key
#  quantity      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fridge_id     :bigint           not null
#  ingredient_id :bigint           not null
#  unit_id       :bigint
#
# Indexes
#
#  index_fridge_ingredients_on_fridge_id      (fridge_id)
#  index_fridge_ingredients_on_ingredient_id  (ingredient_id)
#  index_fridge_ingredients_on_unit_id        (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (fridge_id => fridges.id)
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'rails_helper'

RSpec.describe FridgeIngredient do
  subject { build(:fridge_ingredient) }

  it { is_expected.to belong_to(:fridge) }
  it { is_expected.to belong_to(:ingredient) }
  it { is_expected.to belong_to(:unit).optional }
end
