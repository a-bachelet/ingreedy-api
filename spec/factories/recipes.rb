# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id         :bigint           not null, primary key
#  budget     :enum             default("cheap"), not null
#  cook_time  :integer          default(0), not null
#  image_url  :string           not null
#  name       :string           not null
#  prep_time  :integer          default(0), not null
#  rate       :decimal(, )      default(0.0), not null
#  slug       :string           not null
#  total_time :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_recipes_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :recipe do
    name { 'Mysterious Omelette' }
    slug { 'mysterious-omelette' }
    rate { 3.4 }
    budget { 'luxurious' }
    prep_time { 25 }
    cook_time { 80 }
    total_time { 105 }
    image_url { 'http://images.com/recipe.jpg' }

    transient do
      ingredients_count { 5 }
    end

    recipe_ingredients do
      Array.new(ingredients_count) {
        build(:recipe_ingredient, recipe: nil)
      }
    end

    recipe_tags do
      Array.new(1) {
        build(:recipe_tag, recipe: nil)
      }
    end
  end
end
