# frozen_string_literal: true

ActiveAdmin.register Site do
  menu priority: 1, label: proc { I18n.t('active_admin.sites') }
  permit_params :name, :code, :url, :restrict, :sort
  config.sort_order = 'sort_asc'

  index do
    column :name
    column :code
    column :restrict
    column :sort
    actions
  end
end
