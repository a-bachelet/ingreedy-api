# == Schema Information
#
# Table name: recipes
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :recipe do
    name { "Mysterious Omelette" }

    transient do
      ingredients_count { 5 }
    end

    ingredients do
      Array.new(ingredients_count) { association(:ingredient) }
    end
  end
end
