# frozen_string_literal: true

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
class Suggestion < ApplicationRecord
end
