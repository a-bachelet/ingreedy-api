# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id              :bigint           not null, primary key
#  author_name     :string           default("Ingreedy"), not null
#  author_tip      :string
#  budget          :enum             default("cheap"), not null
#  cook_time       :integer          default(0), not null
#  difficulty      :enum             default("medium"), not null
#  image_url       :string           default(""), not null
#  name            :string           not null
#  people_quantity :integer          default(1), not null
#  prep_time       :integer          default(0), not null
#  rate            :decimal(, )      default(0.0), not null
#  search_vector   :tsvector
#  slug            :string           default(""), not null
#  total_time      :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_recipes_on_search_vector  (search_vector) USING gin
#  index_recipes_on_slug           (slug) UNIQUE
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
      Array.new(ingredients_count) do
        build(:recipe_ingredient, recipe: nil)
      end
    end

    recipe_tags do
      Array.new(1) do
        build(:recipe_tag, recipe: nil)
      end
    end
  end
end
