# frozen_string_literal: true

Time::DATE_FORMATS[:human] = lambda do |date|
  seconds = (Time.now - date).round
  days = seconds / (60 * 60 * 24)
  return date.strftime('%Y年%m月%d日') if days.positive?

  hours = seconds / (60 * 60)
  return "#{hours}時間前" if hours.positive?

  minutes = seconds / 60
  return "#{minutes}分前" if minutes.positive?

  "#{seconds}秒前"
end
