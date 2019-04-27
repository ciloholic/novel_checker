# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'parallel'

namespace :novel_scraping do
  # rakeタスク内のみで使用するメソッド
  # https://qiita.com/hanachin_/items/6cf63dd3987a60e3d264
  top_level = self
  using Module.new {
    refine(top_level.singleton_class) do
      def format_datetime(text = nil)
        return nil if text.blank?

        datetime = text.match('(\d{4}/\d{2}/\d{2} \d{2}:\d{2})')[1]
        Time.zone.parse(datetime).strftime('%Y/%m/%d %H:%M:%S')
      end

      def format_datetime_jp(text = nil, template = nil)
        return nil if text.blank? || template.blank?

        Time.zone.strptime(text, template)
      end

      def url_status(url)
        OpenURI.open_uri(url).status[0].to_i == Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
      rescue StandardError
        false
      end

      def create_url(site = nil, novel = nil)
        case site.code
        when /arcadia|arcadia-r18/
          url = URI(site.url)
          url.query = { act: 'dump', cate: 'all', all: novel.code, n: 0, count: 1 }.to_query
          url.to_s
        when /hameln|hameln-r18/
          URI.join(site.url, '/novel/' + novel.code).to_s
        when 'akatsuki'
          URI.join(site.url, 'novel_id~' + novel.code).to_s
        when /narou|nocturne/
          URI.join(site.url, novel.code).to_s
        else
          raise 'site code error'
        end
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
          url = create_url(site, novel)
          next if url.blank?

          status_code = url_status(url)
          if status_code == false && novel.deleted_at.blank?
            novel.update(deleted_at: Time.zone.now)
          elsif status_code == true && novel.deleted_at.present?
            novel.update(deleted_at: nil)
          end
          random_sleep
        end
      end
    end
  end

  desc 'Scraping the arcadia'
  task arcadia: :environment do
    site = Site.find_by(code: 'arcadia')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="table"]/tr[1]/td[2]/b/a').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="table"]/tr').each do |chapter|
        next if chapter.xpath('td[2]/b/a').text.blank?

        full_url = URI.join(url, chapter.xpath('td[2]/b/a/@href').text)
        chapter_blocks << {
          sub_title: chapter.xpath('td[2]/b/a').text,
          post_at: format_datetime(chapter.xpath('td[4]').text.gsub(/[()]/, '')),
          edit_at: format_datetime(chapter.xpath('td[4]').text.gsub(/[()]/, '')),
          url: full_url.to_s,
          chapter: Rack::Utils.parse_nested_query(full_url.query)['n'].to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url]))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//blockquote/div').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the arcadia-r18'
  task 'arcadia-r18': :environment do
    site = Site.find_by(code: 'arcadia-r18')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="table"]/tr[1]/td[2]/b/a').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="table"]/tr').each do |chapter|
        next if chapter.xpath('td[2]/b/a').text.blank?

        full_url = URI.join(url, chapter.xpath('td[2]/b/a/@href').text)
        chapter_blocks << {
          sub_title: chapter.xpath('td[2]/b/a').text,
          post_at: format_datetime(chapter.xpath('td[4]').text.gsub(/[()]/, '')),
          edit_at: format_datetime(chapter.xpath('td[4]').text.gsub(/[()]/, '')),
          url: full_url.to_s,
          chapter: Rack::Utils.parse_nested_query(full_url.query)['n'].to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url]))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//blockquote/div').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the narou'
  task narou: :environment do
    site = Site.find_by(code: 'narou')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="novel_color"]/p[@class="novel_title"]').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="novel_color"]/div[@class="index_box"]/dl[@class="novel_sublist2"]').each do |chapter|
        next if chapter.xpath('dd[@class="subtitle"]/a/@href').text.blank?

        full_url = URI.join(url, chapter.xpath('dd[@class="subtitle"]/a/@href').text).to_s
        chapter_blocks << {
          sub_title: chapter.xpath('dd[@class="subtitle"]/a').text,
          post_at: format_datetime(chapter.xpath('dt[@class="long_update"]/text()').text.gsub(/[\r\n]/, '')),
          edit_at: format_datetime(chapter.xpath('dt[@class="long_update"]/span/@title').text.gsub(/[\r\n]/, '')),
          url: full_url,
          chapter: full_url.split('/').last.to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url]))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//*[@id="novel_honbun"]').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the hameln'
  task hameln: :environment do
    site = Site.find_by(code: 'hameln')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="maind"]/div[1]/span').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="maind"]/div[3]/table/tr').each do |chapter|
        next if chapter.xpath('td[1]/a/@href').text.blank?

        full_url = URI.join(url, '/novel/' + novel.code + '/' + chapter.xpath('td[1]/a/@href').text).to_s
        chapter_blocks << {
          sub_title: chapter.xpath('td[1]/a').text,
          post_at: format_datetime_jp(chapter.xpath('td[2]/nobr/text()').text.gsub(/\(.\)/, ''), "%Y年%m月%d日 %H:%M"),
          edit_at: format_datetime_jp(chapter.xpath('td[2]/nobr/span/@title').text.gsub(/\(.\)/, ''), "%Y年%m月%d日 %H:%M"),
          url: full_url,
          chapter: full_url.split('/').last.to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url]))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//*[@id="honbun"]').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the akatsuki'
  task akatsuki: :environment do
    site = Site.find_by(code: 'akatsuki')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="LookNovel"]').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//table[@class="list"]/tbody/tr').each do |chapter_block|
        next if chapter_block.xpath('td/a/@href').text.blank?

        full_url = URI.join(url, chapter_block.xpath('td/a/@href').text).to_s
        chapter_blocks << {
          sub_title: chapter_block.xpath('td[1]/a').text,
          post_at: format_datetime_jp(chapter_block.xpath('td[2]').text.gsub(/ |\u00a0/, ''), "%Y年%m月%d日%H時%M分"),
          edit_at: format_datetime_jp(chapter_block.xpath('td[2]').text.gsub(/ |\u00a0/, ''), "%Y年%m月%d日%H時%M分"),
          url: full_url,
          chapter: full_url.split('/').last(2).first.to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url]))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//div[@class="body-novel"]').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the nocturne'
  task nocturne: :environment do
    site = Site.find_by(code: 'nocturne')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url, 'Cookie' => 'over18=yes'))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="novel_color"]/p[@class="novel_title"]').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="novel_color"]/div[@class="index_box"]/dl[@class="novel_sublist2"]').each do |chapter|
        next if chapter.xpath('dd[@class="subtitle"]/a/@href').text.blank?

        full_url = URI.join(url, chapter.xpath('dd[@class="subtitle"]/a/@href').text).to_s
        chapter_blocks << {
          sub_title: chapter.xpath('dd[@class="subtitle"]/a').text,
          post_at: format_datetime(chapter.xpath('dt[@class="long_update"]/text()').text.gsub(/[\r\n]/, '')),
          edit_at: format_datetime(chapter.xpath('dt[@class="long_update"]/span/@title').text.gsub(/[\r\n]/, '')),
          url: full_url,
          chapter: full_url.split('/').last.to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り or 強制時以外はスキップ
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url], 'Cookie' => 'over18=yes'))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//*[@id="novel_honbun"]').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end

  desc 'Scraping the hameln-r18'
  task 'hameln-r18': :environment do
    site = Site.find_by(code: 'hameln-r18')
    Novel.includes(:chapters).where(site_id: site.id, deleted_at: nil).each do |novel|
      begin
        url = create_url(site, novel)
        html = Nokogiri::HTML(Kernel.open(url, 'Cookie' => 'over18=off'))
      rescue StandardError
        next
      end
      random_sleep
      # メインタイトルの保存
      main_title = html.xpath('//*[@id="maind"]/div[1]/span').text
      next if main_title.empty?

      novel.title = main_title
      next unless novel.save

      # チャプターを一括取得
      chapter_blocks = []
      html.xpath('//*[@id="maind"]/div[3]/table/tr').each do |chapter|
        next if chapter.xpath('td[1]/a/@href').text.blank?

        full_url = URI.join(url, '/novel/' + novel.code + '/' + chapter.xpath('td[1]/a/@href').text).to_s
        chapter_blocks << {
          sub_title: chapter.xpath('td[1]/a').text,
          post_at: format_datetime_jp(chapter.xpath('td[2]/nobr/text()').text.gsub(/\(.\)/, ''), "%Y年%m月%d日 %H:%M"),
          edit_at: format_datetime_jp(chapter.xpath('td[2]/nobr/span/@title').text.gsub(/\(.\)/, ''), "%Y年%m月%d日 %H:%M"),
          url: full_url,
          chapter: full_url.split('/').last.to_i
        }
      end
      # 各サブタイトル毎にループ
      chapter_blocks.each do |chapter_block|
        chapter = novel.chapters.find_or_initialize_by(chapter: chapter_block[:chapter])
        # 新規 or 直近1時間以内に更新有り or 強制時以外はスキップ
        next unless chapter.new_record? || (chapter.edit_at || chapter.post_at) >= 1.hour.ago

        begin
          html = Nokogiri::HTML(Kernel.open(chapter_block[:url], 'Cookie' => 'over18=off'))
          random_sleep
          chapter_block.delete(:url)
          chapter_block[:content] = html.xpath('//*[@id="honbun"]').inner_html.gsub(/[\r\n]/, '')
        rescue SocketError, OpenURI::HTTPError
          break
        end
        if chapter.new_record?
          # 新規
          chapter.assign_attributes(chapter_block)
          chapter.save
          Rails.logger.info(format('[%s] C: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        else
          # 更新
          chapter.update(chapter_block)
          Rails.logger.info(format('[%s] U: [%s] [%s]', Time.zone.now.strftime('%Y/%m/%d %H:%M:%S'), novel.title, chapter_block[:sub_title]))
        end
        random_sleep
      end
    end
  end
end
