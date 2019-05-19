# frozen_string_literal: true

require 'test_helper'

class ChapterDecoratorTest < ActiveSupport::TestCase
  def setup
    @chapter = Chapter.new.extend ChapterDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
