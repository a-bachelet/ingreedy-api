# frozen_string_literal: true

# == Schema Information
#
# Table name: fridges
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Fridge < ApplicationRecord
  has_many :fridge_ingredients, dependent: :destroy
  has_many :ingredients, through: :fridge_ingredients
end
