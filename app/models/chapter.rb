# frozen_string_literal: true

# == Schema Information
#
# Table name: chapters
#
#  id         :uuid             not null, primary key
#  chapter    :integer          default(0), not null
#  content    :text
#  edit_at    :datetime
#  post_at    :datetime
#  sub_title  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  novel_id   :uuid
#
# Indexes
#
#  index_chapters_on_novel_id  (novel_id)
#
# Foreign Keys
#
#  fk_rails_...  (novel_id => novels.id)
#

class Chapter < ApplicationRecord
  belongs_to :novel, touch: true

  default_scope { order(novel_id: :asc, chapter: :asc) }

  def self.previous(novel_id, chapter)
    where(novel_id:).reorder(novel_id: :asc, chapter: :desc).find_by('chapter < ?', chapter)
  end

  def self.next(novel_id, chapter)
    where(novel_id:).find_by('chapter > ?', chapter)
  end
end
