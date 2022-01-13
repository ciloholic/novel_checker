# frozen_string_literal: true

class CreateNovels < ActiveRecord::Migration[5.2]
  def up
    create_table :novels do |t|
      t.references :site, foreign_key: true
      t.string :code, null: false
      t.string :title
      t.datetime :deleted_at
      t.timestamps

      t.index %i[site_id code], unique: true
    end
  end

  def down
    drop_table :novels
  end
end
