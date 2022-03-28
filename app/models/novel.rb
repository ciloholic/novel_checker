# frozen_string_literal: true

# == Schema Information
#
# Table name: novels
#
#  id         :uuid             not null, primary key
#  code       :string           not null
#  deleted_at :datetime
#  non_target :boolean          default(FALSE), not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  site_id    :uuid
#
# Indexes
#
#  index_novels_on_site_id           (site_id)
#  index_novels_on_site_id_and_code  (site_id,code) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#

class Novel < ApplicationRecord
  belongs_to :site, touch: true
  has_many :chapters, dependent: :destroy
  accepts_nested_attributes_for :chapters, allow_destroy: true

  default_scope { order(site_id: :asc, code: :asc) }
  scope :select_site, ->(site_id) { includes(:chapters).where(site_id:) }
  scope :published, -> { where(deleted_at: nil).where.not(title: nil) }

  def target_url
    case site.code
    when /arcadia|arcadia-r18/
      url = URI(site.url)
      url.query = { act: 'dump', cate: 'all', all: code, n: 0, count: 1 }.to_query
      url.to_s
    when /hameln|hameln-r18/
      URI.join(site.url, "/novel/#{code}/").to_s
    when 'akatsuki'
      URI.join(site.url, "novel_id~#{code}").to_s
    when /narou|nocturne/
      URI.join(site.url, code).to_s
    when 'other'
      ''
    else
      raise 'site code error'
    end
  end
end
