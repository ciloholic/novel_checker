set :job_template, "/bin/bash -l -i -c ':job'"

hhmm = %w(00 01 02 19 20 21 22 23).map { |hh| "#{hh}:#{rand(1...59).to_s.rjust(2, '0')}" }
every 1.day, at: hhmm do
  rake 'novel_scraping:all_site'
end

every 1.day, at: "#{rand(0...3).to_s.rjust(2, '0')}:#{rand(1...59).to_s.rjust(2, '0')}" do
  rake 'novel_scraping:link_check'
end

every '0 0 * * *' do
  command 'cd /var/www/novel_checker && bundle exec whenever -i'
end
