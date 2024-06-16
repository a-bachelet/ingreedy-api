# == Schema Information
#
# Table name: suggestions
#
#  id                 :bigint           not null, primary key
#  ingredients        :jsonb            not null
#  perfect_match_only :boolean          default(FALSE), not null
#  recipes            :jsonb            not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Suggestion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
