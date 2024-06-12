# frozen_string_literal: true

# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Ingredient do
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:recipe_ingredients) }
  it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }

  it { is_expected.to have_many(:fridge_ingredients) }
  it { is_expected.to have_many(:fridges).through(:fridge_ingredients) }
end
