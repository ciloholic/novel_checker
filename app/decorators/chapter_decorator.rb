# frozen_string_literal: true

module ChapterDecorator
  def replace_sub_title
    sub_title.gsub(/　/, ' ')
  end
end
