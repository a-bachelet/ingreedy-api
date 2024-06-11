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
  it 'is valid with a name' do
    ingredient = described_class.new(name: 'Salt')
    expect(ingredient).to be_valid
  end

  it 'is invalid without a name' do
    ingredient = described_class.new(name: nil)
    expect(ingredient).not_to be_valid
  end
end
