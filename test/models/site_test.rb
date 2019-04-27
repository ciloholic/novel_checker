# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  code       :string(255)      not null
#  url        :string(255)      not null
#  sort       :bigint(8)        not null
#  restrict   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
