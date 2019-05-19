# frozen_string_literal: true

require 'test_helper'

class NovelDecoratorTest < ActiveSupport::TestCase
  def setup
    @novel = Novel.new.extend NovelDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
