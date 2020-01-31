# frozen_string_literal: true

module NovelDecorator
  def replace_title
    title.gsub(/　/, ' ')
  end

  def replace_sub_title
    sub_title.gsub(/　/, ' ')
  end

  def string_restrict
    self.site.restrict ? '[R-18]' : ''
  end
end
