# frozen_string_literal: true

# == Schema Information
#
# Table name: novels
#
#  id         :bigint(8)        not null, primary key
#  site_id    :bigint(8)
#  code       :string(255)      not null
#  title      :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Novel < ApplicationRecord
  belongs_to :site, touch: true
  has_many :chapters, dependent: :destroy
  accepts_nested_attributes_for :chapters, allow_destroy: true
  default_scope { order(site_id: :asc, code: :asc) }

  scope :select_site, ->(site_id) { includes(:chapters).where(site_id: site_id) }

  def target_url
    case site.code
    when /arcadia|arcadia-r18/
      url = URI(site.url)
      url.query = { act: 'dump', cate: 'all', all: code, n: 0, count: 1 }.to_query
      url.to_s
    when /hameln|hameln-r18/
      URI.join(site.url, '/novel/' + code).to_s
    when 'akatsuki'
      URI.join(site.url, 'novel_id~' + code).to_s
    when /narou|nocturne/
      URI.join(site.url, code).to_s
    else
      raise 'site code error'
    end
  end
end
