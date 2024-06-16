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
require 'rails_helper'

RSpec.describe Ingredient do
  subject { build(:ingredient) }

  it { is_expected.to validate_presence_of(:names) }

  it { is_expected.to have_many(:recipe_ingredients) }
  it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }
end
