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
require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject { build(:tag) }
  
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:slug) }
  
  it { is_expected.to validate_uniqueness_of(:slug) }
end
