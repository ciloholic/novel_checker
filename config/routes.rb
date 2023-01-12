# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :sites
    resources :novels
    resources :chapters
    resources :scraping_statuses

    root to: 'novels#index'
  end

  get ':code/:novel_id', to: 'site#index', code: /[a-z0-9-]+/, novel_id: /[0-9a-f-]+/
  get ':code/:novel_id/:chapter_id', to: 'site#show', code: /[a-z0-9-]+/, novel_id: /[0-9a-f-]+/, chapter_id: /[0-9a-f-]+/

  root to: 'site#top'
  match '*any' => 'application#render404', via: :all
end
