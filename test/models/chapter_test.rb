# frozen_string_literal: true

# == Schema Information
#
# Table name: chapters
#
#  id         :bigint           not null, primary key
#  novel_id   :bigint
#  chapter    :integer          default(0), not null
#  sub_title  :string(255)
#  content    :text(16777215)
#  post_at    :datetime
#  edit_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ChapterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
