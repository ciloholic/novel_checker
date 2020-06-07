# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'parallel'
require 'novel_scraping'

namespace :novel_scraping do
  # rakeタスク内のみで使用するメソッド
  # https://qiita.com/hanachin_/items/6cf63dd3987a60e3d264
  top_level = self
  using Module.new {
    refine(top_level.singleton_class) do
      def scraping(code)
        site = Site.find_by!(code: code)
        Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil, non_target: 0).each do |novel|
          begin
            novel.title, chapter_blocks =
              if novel.title.empty?
                NovelScraping.access(novel.target_url)
              else
                NovelScraping.access(novel.target_url, from: novel.chapters.maximum(:edit_at) + 1)
              end
          rescue StandardError
            next
          end
          next if novel.title.empty?

          novel.save! if novel.title_changed?
          chapter_blocks.each do |chapter_block|
            chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:count])
            chapter_block = chapter_block.slice(:sub_title, :content, :post_at, :edit_at)
            if chapter.new_record?
              chapter.assign_attributes(chapter_block)
              chapter.save!
              Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
            else
              chapter.update!(chapter_block)
              Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
            end
          end
        end
        scraping_status = ScrapingStatus.find_or_initialize_by(site_id: site.id)
        scraping_status.update!(executing_time: Time.zone.now)
      end

      def url_status(url)
        OpenURI.open_uri(url).status[0].to_i == Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
      rescue StandardError
        false
      end

      def random_sleep(min: 1, max: 4)
        sleep([*min..max].sample)
      end
    end
  }

  desc 'Scraping the site'
  task all_site: :environment do
    Parallel.each(Site.where.not(code: 'other'), in_processes: 6) do |site|
      ActiveRecord::Base.connection_pool.with_connection do
        Rake::Task["novel_scraping:#{site.code}"].execute
      end
    end
  end

  desc 'Check for broken links'
  task link_check: :environment do
    Parallel.each(Site.where.not(code: 'other'), in_processes: 6) do |site|
      ActiveRecord::Base.connection_pool.with_connection do
        Novel.where(site_id: site.id).each do |novel|
          url = novel.target_url
          next if url.blank?

          status_code = url_status(url)
          if !status_code && novel.deleted_at.blank?
            novel.update_column(:deleted_at, Time.zone.now)
          elsif status_code && novel.deleted_at.present?
            novel.update_column(:deleted_at, nil)
          end
          random_sleep
        end
      end
    end
  end

  desc 'Scraping the arcadia'
  task arcadia: :environment do
    scraping('arcadia')
  end

  desc 'Scraping the arcadia-r18'
  task 'arcadia-r18': :environment do
    scraping('arcadia-r18')
  end

  desc 'Scraping the narou'
  task narou: :environment do
    scraping('narou')
  end

  desc 'Scraping the hameln'
  task hameln: :environment do
    scraping('hameln')
  end

  desc 'Scraping the akatsuki'
  task akatsuki: :environment do
    scraping('akatsuki')
  end

  desc 'Scraping the nocturne'
  task nocturne: :environment do
    scraping('nocturne')
  end

  desc 'Scraping the hameln-r18'
  task 'hameln-r18': :environment do
    scraping('hameln-r18')
  end
end
