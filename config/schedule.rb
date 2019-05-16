every 1.hour do
  rake 'novel_scraping:all_site'
end

every 1.day, at: '0:30 am' do
  rake 'novel_scraping:link_check'
end
