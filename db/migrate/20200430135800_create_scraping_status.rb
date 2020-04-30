class CreateScrapingStatus < ActiveRecord::Migration[6.0]
  def up
    create_table :scraping_statuses do |t|
      t.references :site, foreign_key: true
      t.datetime :executing_time
    end
  end

  def down
    drop_table :scraping_statuses
  end
end
