# frozen_string_literal: true

# == Schema Information
#
# Table name: fridge_ingredients
#
#  quantity      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fridge_id     :bigint           not null, primary key
#  ingredient_id :bigint           not null, primary key
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
class FridgeIngredient < ApplicationRecord
  belongs_to :fridge
  belongs_to :ingredient
  belongs_to :unit, optional: true

  self.primary_key = %i[fridge_id ingredient_id]

  validates :ingredient_id, uniqueness: { scope: :fridge_id, message: 'Ingredient is already in the fridge.' } # rubocop:disable Rails/I18nLocaleTexts, Rails/UniqueValidationWithoutIndex

  def self.to_json_list
    data = joins(:ingredient)
      .left_joins(:unit)
      .select(:ingredient_id, :quantity, :unit_id, 
              'ingredients.names AS ingredient_names',
              'units.names AS unit_names'
             )
  end
end
