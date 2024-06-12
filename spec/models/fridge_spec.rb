# == Schema Information
#
# Table name: fridges
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Fridge, type: :model do
  it { should have_many(:fridge_ingredients) }
  it { should have_many(:ingredients).through(:fridge_ingredients) }
end
