# == Schema Information
#
# Table name: units
#
#  id         :bigint           not null, primary key
#  names      :string           default("{:singular=>\"\", :plural=>\"\"}"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :unit do
    names { { singular: 'cuillère à café', plural: 'cuillères à café' } }
  end
end
