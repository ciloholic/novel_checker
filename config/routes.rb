Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  site_code = Rails.cache.fetch('routes-site-code-pluck', expired_in: 1.hour) do
    Site.pluck(:code).join('|')
  end
  regexp = Regexp.new(site_code)
  get ':code/:novel_id', to: 'site#index', code: regexp, novel_id: /[0-9]+/
  get ':code/:novel_id/:chapter_id', to: 'site#show', code: regexp, novel_id: /[0-9]+/, chapter_id: /[0-9]+/

  root to: 'site#top'
  match '*any' => 'application#render_404', via: :all
end
