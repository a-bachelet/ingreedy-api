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
  it { should validate_presence_of(:name) }

  it { should have_many(:recipe_ingredients) }
  it { should have_many(:recipes).through(:recipe_ingredients) }

  it { should have_many(:fridge_ingredients) }
  it { should have_many(:fridges).through(:fridge_ingredients) }
end
