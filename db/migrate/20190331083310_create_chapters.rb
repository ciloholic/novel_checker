class CreateChapters < ActiveRecord::Migration[5.2]
  def up
    create_table :chapters do |t|
      t.references :novel, foreign_key: true
      t.integer :chapter, default: 0, null: false
      t.string :sub_title
      t.mediumtext :content
      t.datetime :post_at
      t.datetime :edit_at
      t.timestamps null: false
    end
  end

  def down
    drop_table :chapters
  end
end
