# frozen_string_literal: true

# == Schema Information
#
# Table name: recipe_tags
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  recipe_id  :bigint           not null, primary key
#  tag_id     :bigint           not null, primary key
#
# Indexes
#
#  index_recipe_tags_on_recipe_id  (recipe_id)
#  index_recipe_tags_on_tag_id     (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_id => recipes.id)
#  fk_rails_...  (tag_id => tags.id)
#
FactoryBot.define do
  factory :recipe_tag do
    association :recipe, strategy: :build
    association :tag, strategy: :build
  end
end
