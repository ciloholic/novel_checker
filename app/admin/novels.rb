# frozen_string_literal: true

ActiveAdmin.register Novel do
  menu priority: 2, label: proc { I18n.t('active_admin.novels') }
  permit_params :site_id, :code, :title, :deleted_at

  index do
    column :site
    column :code
    column :title
    column :non_target
    column :deleted_at
    actions
  end

  controller do
    def find_collection(options = {})
      super.reorder(site_id: :asc, non_target: :asc, code: :asc)
    end
  end
end
