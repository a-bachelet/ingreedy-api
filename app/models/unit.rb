# == Schema Information
#
# Table name: units
#
#  id         :bigint           not null, primary key
#  names      :string           default("{:singular=>\"\", :plural=>\"\"}"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Unit < ApplicationRecord
  validates :names, presence: true
end
