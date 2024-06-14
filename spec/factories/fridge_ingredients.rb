# frozen_string_literal: true

# == Schema Information
#
# Table name: fridge_ingredients
#
#  id            :bigint           not null, primary key
#  quantity      :integer          not null
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
FactoryBot.define do
  factory :fridge_ingredient do
    association :fridge, strategy: :build
    association :ingredient, strategy: :build
    association :unit, strategy: :build

    quantity { 1 }
  end
end
