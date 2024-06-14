# frozen_string_literal: true

# == Schema Information
#
# Table name: fridges
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Fridge do
  subject { build(:fridge) }

  it { is_expected.to have_many(:fridge_ingredients) }
  it { is_expected.to have_many(:ingredients).through(:fridge_ingredients) }
end
