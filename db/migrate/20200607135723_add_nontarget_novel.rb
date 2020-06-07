class AddNontargetNovel < ActiveRecord::Migration[6.0]
  def up
    add_column :novels, :non_target, :boolean, null: false, default: false
  end

  def down
    remove_column :novels, :non_target, :boolean
  end
end
