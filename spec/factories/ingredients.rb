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
FactoryBot.define do
  factory :ingredient do
    names { { singula: 'Mysterious egg', plural: 'Mysterious eggs' } }
  end
end
