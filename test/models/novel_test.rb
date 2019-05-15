# frozen_string_literal: true

# == Schema Information
#
# Table name: novels
#
#  id         :bigint           not null, primary key
#  site_id    :bigint
#  code       :string(255)      not null
#  title      :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class NovelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
