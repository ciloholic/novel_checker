# frozen_string_literal: true

# == Schema Information
#
# Table name: chapters
#
#  id         :bigint(8)        not null, primary key
#  novel_id   :bigint(8)
#  chapter    :integer          default(0), not null
#  sub_title  :string(255)
#  content    :text(16777215)
#  post_at    :datetime
#  edit_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chapter < ApplicationRecord
  belongs_to :novel, touch: true
  default_scope { order(novel_id: :asc, chapter: :asc) }

  def self.previous(novel_id, chapter)
    where(novel_id: novel_id).reorder(novel_id: :asc, chapter: :desc).find_by('chapter < ?', chapter)
  end

  def self.next(novel_id, chapter)
    where(novel_id: novel_id).find_by('chapter > ?', chapter)
  end
end
