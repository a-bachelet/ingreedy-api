# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :tag do
    name { 'Plat principal' }
    slug { 'plat-principal' }
  end
end
