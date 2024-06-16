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
class Recipe < ApplicationRecord
  include PgSearch::Model

  enum budget: {
    cheap: 'cheap',
    affordable: 'affordable',
    medium: 'medium',
    high: 'high',
    very_high: 'very_high',
    luxurious: 'luxurious'
  }, _prefix: true

  enum difficulty: {
    very_easy: 'very_easy',
    easy: 'easy',
    medium: 'medium',
    difficult: 'difficult'
  }, _prefix: true

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :image_url, presence: true

  pg_search_scope(
    :search,
    using: {
      tsearch: {
        dictionary: 'french',
        tsvector_column: 'search_vector'
      }
    }
  )

  def self.to_json_list
    author_sql = <<-SQL
      JSON_BUILD_OBJECT(
        'name', recipes.author_name,
        'tip', recipes.author_tip
      ) AS author
    SQL

    times_sql = <<-SQL
      JSON_BUILD_OBJECT(
        'preparation', recipes.prep_time,
        'cooking', recipes.cook_time,
        'total', recipes.total_time
      ) AS times
    SQL

    ingredients_sql = <<-SQL
      JSON_AGG(JSON_BUILD_OBJECT(
        'names', ingredients.names,
        'quantity', recipe_ingredients.quantity,
        'unit_names', units.names
      )) AS ingredients
    SQL

    data = self
      .joins('INNER JOIN recipe_ingredients ON recipe_ingredients.recipe_id = recipes.id')
      .joins('INNER JOIN ingredients ON ingredients.id = recipe_ingredients.ingredient_id')
      .joins('LEFT OUTER JOIN units ON units.id = recipe_ingredients.unit_id')
      .group(:id, :name, :slug, :rate, :budget, :people_quantity, :difficulty, :image_url,
             :author_name, :author_tip, :prep_time, :cook_time, :total_time)
      .select(:id, :name, :slug, :rate, :budget, :people_quantity, :difficulty, :image_url)
      .select(author_sql, times_sql, ingredients_sql)

    data.all.map do |datum|
      {
        id: datum.id, name: datum.name, rate: datum.rate, budget: datum.budget, peaople_quantity: datum.people_quantity,
        difficulty: datum.difficulty, image_url: datum.image_url, author: datum['author'], times: datum['times'],
        ingredients: datum['ingredients']
      }
    end
  end
end
