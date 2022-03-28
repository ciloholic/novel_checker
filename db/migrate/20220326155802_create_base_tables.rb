class CreateBaseTables < ActiveRecord::Migration[7.0]
  def up
    create_table :sites, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :url, null: false
      t.bigint :sort, null: false
      t.boolean :restrict, null: false, default: false
      t.timestamps

      t.index :code, unique: true
    end

    create_table :novels, id: :uuid do |t|
      t.references :site, type: :uuid, foreign_key: true
      t.string :code, null: false
      t.string :title
      t.boolean :non_target, null: false, default: false
      t.datetime :deleted_at
      t.timestamps

      t.index %i[site_id code], unique: true
    end

    create_table :chapters, id: :uuid do |t|
      t.references :novel, type: :uuid, foreign_key: true
      t.integer :chapter, default: 0, null: false
      t.string :sub_title
      t.text :content
      t.datetime :post_at
      t.datetime :edit_at
      t.timestamps null: false
    end

    create_table :scraping_statuses, id: :uuid do |t|
      t.references :site, type: :uuid, foreign_key: true
      t.datetime :executing_time
    end
  end

  def down
    drop_table :scraping_statuses
    drop_table :chapters
    drop_table :novels
    drop_table :sites
  end
end
