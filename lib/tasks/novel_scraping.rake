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
      def scraping(code, force: false)
        site = Site.find_by!(code:)
        Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).find_each do |novel|
          unless !novel.non_target || force
            Rails.logger.info(format('[%s] skip non target', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S')))
            next
          end

          begin
            novel.title, chapter_blocks =
              if novel.title.blank?
                NovelScraping.access(novel.target_url)
              else
                NovelScraping.access(novel.target_url, from: novel.chapters.maximum(:edit_at) + 1)
              end
          rescue StandardError
            next
          end
          next if novel.title.blank?

          novel.save! if novel.title_changed?
          chapter_blocks.each do |chapter_block|
            chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:count])
            chapter_block = chapter_block.slice(:sub_title, :content, :post_at, :edit_at)
            if chapter.new_record?
              chapter.assign_attributes(chapter_block)
              chapter.save!
              Rails.logger.info(format('[%<time>s] C: [%<title>s] [%<sub_title>s]', time: Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), title: novel.title, sub_title: chapter_block[:sub_title]))
            else
              chapter.update!(chapter_block)
              Rails.logger.info(format('[%<time>s] U: [%<title>s] [%<sub_title>s]', time: Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), title: novel.title, sub_title: chapter_block[:sub_title]))
            end
          end
        end
        scraping_status = ScrapingStatus.find_or_initialize_by(site_id: site.id)
        scraping_status.update!(executing_time: Time.zone.now)
      end

      def url_status(url, option = {})
        res = Faraday.get(url) do |req|
          req.headers['Cookie'] = option[:cookie] if option.key?(:cookie)
        end
        res.status == Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
      rescue StandardError
        false
      end

      def random_sleep(min: 1, max: 4)
        sleep(rand(min..max))
      end
    end
  }

  desc 'Scraping the site'
  task :all_site, ['force'] => :environment do |_, args|
    Parallel.each(Site.where.not(code: 'other'), in_processes: 2) do |site|
      ActiveRecord::Base.connection_pool.with_connection do
        Rake::Task["novel_scraping:#{site.code}"]
          .execute(force: ActiveRecord::Type::Boolean.new.cast(args['force']).present?)
      end
    end
  end

  desc 'No renewal for one month'
  task no_renewal_check: :environment do
    Parallel.each(Site.where.not(code: 'other'), in_processes: 2) do |site|
      ActiveRecord::Base.connection_pool.with_connection do
        Novel.where(site_id: site.id, deleted_at: nil, non_target: 0).where.not(updated_at: 1.month.ago..Float::INFINITY).find_each do |novel|
          novel.update(non_target: true)
        end
      end
    end
  end

  desc 'Check for broken links'
  task link_check: :environment do
    Parallel.each(Site.where.not(code: 'other'), in_processes: 2) do |site|
      ActiveRecord::Base.connection_pool.with_connection do
        Novel.where(site_id: site.id).find_each do |novel|
          url = novel.target_url
          next if url.blank?

          option = {}.tap do |x|
            x[:cookie] = 'over18=yes' if site.code == 'nocturne'
            x[:cookie] = 'over18=off' if site.code == 'hameln-r18'
          end
          status_code = url_status(url, option)
          if !status_code && novel.deleted_at.blank?
            novel.update(deleted_at: Time.zone.now)
          elsif status_code && novel.deleted_at.present?
            novel.update(deleted_at: nil)
          end
          random_sleep
        end
      end
    end
  end

  desc 'Scraping the arcadia'
  task :arcadia, ['force'] => :environment do |_, args|
    scraping('arcadia', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the arcadia-r18'
  task :'arcadia-r18', ['force'] => :environment do |_, args|
    scraping('arcadia-r18', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the narou'
  task :narou, ['force'] => :environment do |_, args|
    scraping('narou', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the hameln'
  task :hameln, ['force'] => :environment do |_, args|
    scraping('hameln', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the akatsuki'
  task :akatsuki, ['force'] => :environment do |_, args|
    scraping('akatsuki', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the nocturne'
  task :nocturne, ['force'] => :environment do |_, args|
    scraping('nocturne', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end

  desc 'Scraping the hameln-r18'
  task :'hameln-r18', ['force'] => :environment do |_, args|
    scraping('hameln-r18', force: ActiveRecord::Type::Boolean.new.cast(args[:force]) || false)
  end
end
