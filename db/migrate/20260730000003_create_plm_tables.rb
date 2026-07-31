class CreatePlmTables < ActiveRecord::Migration[8.1]
  def change
    # 1. 添加产品生命周期状态字段（保留原 status 兼容）
    add_column :products, :lifecycle_state, :string, default: 'concept', null: false
    add_column :products, :lifecycle_updated_at, :datetime

    # 2. 生命周期历史记录表
    create_table :lifecycle_histories do |t|
      t.references :product, null: false, foreign_key: true
      t.string :from_state
      t.string :to_state, null: false
      t.references :changed_by, foreign_key: { to_table: :users }
      t.text :remark
      t.timestamps
    end

    # 3. 技术文档表
    create_table :documents do |t|
      t.string :title, null: false
      t.string :doc_number, null: false  # 文档编号
      t.string :doc_type, null: false   # spec/test_report/certification/manual/drawing/other
      t.references :product, foreign_key: true
      t.references :design_drawing, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :current_version, default: '0.1'
      t.string :status, default: 'draft' # draft/submitted/approved/released/superseded
      t.text :description
      t.timestamps
    end
    add_index :documents, :doc_number, unique: true
    add_index :documents, :doc_type
    add_index :documents, :status

    # 4. 文档版本表
    create_table :document_versions do |t|
      t.references :document, null: false, foreign_key: true
      t.string :version, null: false      # 版本号，如 1.0, 1.1, 2.0
      t.references :uploaded_by, foreign_key: { to_table: :users }
      t.string :status, default: 'draft'  # draft/submitted/approved/released/superseded
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.datetime :released_at
      t.text :change_summary               # 本版本变更说明
      t.timestamps
    end
    add_index :document_versions, [:document_id, :version], unique: true
    add_index :document_versions, :status
  end
end
