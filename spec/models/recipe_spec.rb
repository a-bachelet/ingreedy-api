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

RSpec.describe Recipe, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:recipe_ingredients) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
end
