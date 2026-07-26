class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false, limit: 200
      t.string :code, null: false, limit: 50
      t.string :short_name, limit: 100
      t.string :supplier_type, default: 'parts'   # raw_material/parts/outsourcing/packaging/logistics
      t.string :contact_person, limit: 50
      t.string :phone, limit: 50
      t.string :email, limit: 100
      t.string :address, limit: 300
      t.string :bank_name, limit: 100
      t.string :bank_account, limit: 50
      t.string :tax_number, limit: 50
      t.string :status, default: 'active'         # active/inactive/blacklisted
      t.string :level, default: 'b'                # a/b/c
      t.text :remark
      t.timestamps
    end

    add_index :suppliers, :code, unique: true
    add_index :suppliers, :status
    add_index :suppliers, :supplier_type
  end
end
