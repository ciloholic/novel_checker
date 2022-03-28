# frozen_string_literal: true

# == Schema Information
#
# Table name: scraping_statuses
#
#  id             :uuid             not null, primary key
#  executing_time :datetime
#  site_id        :uuid
#
# Indexes
#
#  index_scraping_statuses_on_site_id  (site_id)
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#

class ScrapingStatus < ApplicationRecord
  belongs_to :site

  default_scope { order(site_id: :asc) }
end
