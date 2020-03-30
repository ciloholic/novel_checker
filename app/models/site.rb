# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  code       :string(255)      not null
#  url        :string(255)      not null
#  sort       :bigint           not null
#  restrict   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Site < ApplicationRecord
  include CacheSupport
  has_many :novels, dependent: :destroy
  accepts_nested_attributes_for :novels, allow_destroy: true
  default_scope { order(sort: :asc) }
  scope :published, -> { includes(:novels).where.not(novels: { title: '' }) }
end
