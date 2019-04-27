# frozen_string_literal: true

ActiveAdmin.register Chapter do
  menu priority: 3, label: proc { I18n.t('active_admin.chapters') }

  index do
    column :id
    column :novel
    column :sub_title
    column :post_at
    column :edit_at
    actions
  end

  controller do
    def find_collection(options = {})
      super.reorder(novel_id: :asc, chapter: :asc)
    end
  end
end
