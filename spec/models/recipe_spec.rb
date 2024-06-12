# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Recipe do
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:recipe_ingredients) }
  it { is_expected.to have_many(:ingredients).through(:recipe_ingredients) }
end
