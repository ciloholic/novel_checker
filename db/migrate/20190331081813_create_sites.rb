# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[5.2]
  def up
    create_table :sites do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :url, null: false
      t.bigint :sort, null: false
      t.boolean :restrict, null: false, default: false
      t.timestamps
    end
  end

  def down
    drop_table :sites
  end
end
