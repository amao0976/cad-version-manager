class CreateInspectionTables < ActiveRecord::Migration[8.0]
  def change
    # 工厂表
    create_table :factories do |t|
      t.string :name, null: false
      t.references :supplier, null: false, foreign_key: true
      t.string :address
      t.string :city
      t.string :province
      t.string :country
      t.text :remarks
      t.timestamps
    end
    add_index :factories, [:supplier_id, :name], unique: true

    # 验货申请表
    create_table :inspection_requests do |t|
      t.references :product, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :factory, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :inspection_id
      t.string :supplier_name
      t.string :factory_name
      t.string :order_number, null: false
      t.string :style_number, null: false
      t.integer :quantity, null: false
      t.date :requested_date, null: false
      t.string :inspection_type
      t.string :status, default: 'pending', null: false
      t.string :result
      t.text :remarks
      t.text :ps_comments
      t.timestamps
    end
    add_index :inspection_requests, :status
    add_index :inspection_requests, :order_number
    add_index :inspection_requests, :inspection_id

    # 验货申请明细项
    create_table :inspection_request_items do |t|
      t.references :inspection_request, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :style_number, null: false
      t.integer :quantity, null: false
      t.string :inspection_level, default: 'II', null: false
      t.string :aql_level, default: '2.5', null: false
      t.integer :sample_size
      t.integer :accept_qty
      t.integer :reject_qty
      t.string :code_letter
      t.timestamps
    end
    add_index :inspection_request_items, :order_number

    # 验货记录表
    create_table :inspections do |t|
      t.references :product, foreign_key: true
      t.references :supplier, foreign_key: true
      t.references :factory, foreign_key: true
      t.references :inspection_request, foreign_key: true
      t.string :supplier_name
      t.string :supplier_category
      t.string :factory_name
      t.string :country
      t.string :province
      t.string :city
      t.date :inspection_date, null: false
      t.string :order_no, null: false
      t.string :reference_no, null: false
      t.integer :week
      t.integer :order_quantity
      t.integer :shipment_quantity
      t.date :requested_date
      t.string :inspection_type
      t.string :buyer
      t.string :set_name
      t.string :fabric_name
      t.string :color
      t.string :qc_name
      t.integer :major_defects, default: 0
      t.integer :minor_defects, default: 0
      t.integer :qty_rejected, default: 0
      t.string :result
      t.string :rfid_checking
      t.string :chemical_test
      t.string :physical_test
      t.string :transport
      t.string :etd
      t.text :comments
      t.text :ps_comments
      t.timestamps
    end
    add_index :inspections, :inspection_date
    add_index :inspections, :order_no
    add_index :inspections, :reference_no
    add_index :inspections, :supplier_category

    # 验货报告表
    create_table :inspection_reports do |t|
      t.references :inspection, null: false, foreign_key: true, index: { unique: true }
      t.string :status, default: 'draft'
      t.string :style_description
      t.string :color
      t.string :material_composition
      t.string :size_range
      t.text :size_table
      t.text :summary
      t.text :product_remarks
      t.timestamps
    end
  end
end
