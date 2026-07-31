class CreateGuides < ActiveRecord::Migration[8.0]
  def change
    create_table :guides do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content_md, null: false  # Markdown 内容
      t.text :content_html             # 渲染后的 HTML 缓存
      t.references :guide_category, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.references :product, foreign_key: true, null: true
      t.string :status, default: 'draft', null: false  # draft / published / archived
      t.integer :views_count, default: 0
      t.datetime :published_at
      t.timestamps
    end
    add_index :guides, :slug, unique: true
    add_index :guides, :status
    add_index :guides, :published_at
  end
end
