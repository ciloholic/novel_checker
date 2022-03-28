# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id         :uuid             not null, primary key
#  code       :string           not null
#  name       :string           not null
#  restrict   :boolean          default(FALSE), not null
#  sort       :bigint           not null
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sites_on_code  (code) UNIQUE
#

class Site < ApplicationRecord
  include CacheSupport

  has_many :novels, dependent: :destroy
  has_one :scraping_status, dependent: :destroy

  scope :sort_asc, -> { order(sort: :asc) }
  scope :published, -> { includes(:novels).where.not(novels: { title: '' }) }
end
