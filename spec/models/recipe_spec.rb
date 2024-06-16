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
require 'rails_helper'

RSpec.describe Recipe do
  subject { build(:recipe) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:image_url) }

  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to have_many(:recipe_ingredients) }
  it { is_expected.to have_many(:ingredients).through(:recipe_ingredients) }

  it { is_expected.to have_many(:recipe_tags) }
  it { is_expected.to have_many(:tags).through(:recipe_tags) }
end
