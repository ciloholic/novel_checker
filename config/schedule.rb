# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

set :job_template, "/bin/bash -l -i -c ':job'"

hhmm = [*0..23].map { |hh| "#{hh.to_s.rjust(2, '0')}:#{rand(1...59).to_s.rjust(2, '0')}" }
if Time.zone.now.day == 1
  hhmm.pop
  every 1.day, at: '23:00' do
    rake 'novel_scraping:all_site[true]'
  end
end
every 1.day, at: hhmm do
  rake 'novel_scraping:all_site'
end

every 1.day, at: "#{rand(0...3).to_s.rjust(2, '0')}:#{rand(1...59).to_s.rjust(2, '0')}" do
  rake 'novel_scraping:link_check'
end

every '0 0 * * 0' do
  rake 'novel_scraping:no_renewal_check'
end

every '0 0 * * *' do
  command 'cd /app && bundle exec whenever -i'
end
