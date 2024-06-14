# == Schema Information
#
# Table name: units
#
#  id         :bigint           not null, primary key
#  names      :string           default("{:singular=>\"\", :plural=>\"\"}"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Unit, type: :model do
  subject { build(:unit) }

  it { is_expected.to validate_presence_of(:names) }
end
