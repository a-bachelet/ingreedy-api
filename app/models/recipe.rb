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
class Recipe < ApplicationRecord
  enum budget: {
    cheap: 'cheap',
    affordable: 'affordable',
    medium: 'medium',
    high: 'high',
    very_high: 'very_high',
    luxurious: 'luxurious'
  }, _prefix: true

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :image_url, presence: true
end
