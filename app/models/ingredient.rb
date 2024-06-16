# frozen_string_literal: true

# == Schema Information
#
# Table name: ingredients
#
#  id            :bigint           not null, primary key
#  names         :jsonb            not null
#  search_vector :tsvector
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_ingredients_on_search_vector  (search_vector) USING gin
#
class Ingredient < ApplicationRecord
  include PgSearch::Model

  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :names, presence: true

  pg_search_scope(
    :search,
    against: :names,
    using: {
      tsearch: {
        dictionary: 'french',
        tsvector_column: 'search_vector'
      }
    }
  )
end
