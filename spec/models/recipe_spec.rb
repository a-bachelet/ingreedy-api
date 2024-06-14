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
