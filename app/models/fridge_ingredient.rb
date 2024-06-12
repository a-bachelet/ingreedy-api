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
#
# Indexes
#
#  index_fridge_ingredients_on_fridge_id      (fridge_id)
#  index_fridge_ingredients_on_ingredient_id  (ingredient_id)
#
# Foreign Keys
#
#  fk_rails_...  (fridge_id => fridges.id)
#  fk_rails_...  (ingredient_id => ingredients.id)
#
class FridgeIngredient < ApplicationRecord
  belongs_to :fridge
  belongs_to :ingredient

  validates :quantity, presence: true
end
