# frozen_string_literal: true

# == Schema Information
#
# Table name: fridges
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :fridge
end
