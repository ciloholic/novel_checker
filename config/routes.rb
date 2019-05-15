Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get ':code/:novel_id', to: 'site#index', code: /[a-z0-9\-]+/, novel_id: /[0-9]+/
  get ':code/:novel_id/:chapter_id', to: 'site#show', code: /[a-z0-9\-]+/, novel_id: /[0-9]+/, chapter_id: /[0-9]+/

  root to: 'site#top'
  match '*any' => 'application#render_404', via: :all
end
