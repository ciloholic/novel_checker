# frozen_string_literal: true

# == Schema Information
#
# Table name: scraping_statuses
#
#  id             :bigint           not null, primary key
#  site_id        :bigint
#  executing_time :datetime
#

class ScrapingStatus < ApplicationRecord
  belongs_to :site

  default_scope { order(site_id: :asc) }
end
