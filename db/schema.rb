# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_31_000010) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["expires_at"], name: "index_api_tokens_on_expires_at"
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "batches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "number", limit: 50, null: false
    t.integer "product_id", null: false
    t.date "production_date"
    t.integer "quantity", default: 0, null: false
    t.text "remark"
    t.string "status", default: "in_production", null: false
    t.string "supplier"
    t.datetime "updated_at", null: false
    t.integer "variant_id"
    t.index ["number"], name: "index_batches_on_number", unique: true
    t.index ["product_id"], name: "index_batches_on_product_id"
    t.index ["status"], name: "index_batches_on_status"
    t.index ["variant_id"], name: "index_batches_on_variant_id"
  end

  create_table "bom_items", force: :cascade do |t|
    t.integer "color_id"
    t.datetime "created_at", null: false
    t.integer "design_drawing_id"
    t.integer "level", default: 1
    t.string "material"
    t.integer "parent_id"
    t.string "part_name", null: false
    t.string "part_number", null: false
    t.integer "product_bom_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.string "source", default: "自制"
    t.string "specification"
    t.string "unit", default: "件"
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 4
    t.index ["color_id"], name: "index_bom_items_on_color_id"
    t.index ["design_drawing_id"], name: "index_bom_items_on_design_drawing_id"
    t.index ["parent_id"], name: "index_bom_items_on_parent_id"
    t.index ["product_bom_id"], name: "index_bom_items_on_product_bom_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", limit: 100, null: false
    t.integer "parent_id"
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_categories_on_code", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "colors", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.string "color_type", default: "plating", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "hex_code"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_colors_on_active"
    t.index ["code"], name: "index_colors_on_code", unique: true
    t.index ["color_type"], name: "index_colors_on_color_type"
  end

  create_table "design_drawings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.integer "design_project_id", null: false
    t.string "drawing_code"
    t.string "file_type"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_design_drawings_on_created_by_id"
    t.index ["design_project_id"], name: "index_design_drawings_on_design_project_id"
    t.index ["drawing_code"], name: "index_design_drawings_on_drawing_code", unique: true
    t.index ["file_type"], name: "index_design_drawings_on_file_type"
  end

  create_table "design_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_design_projects_on_created_by_id"
    t.index ["status"], name: "index_design_projects_on_status"
  end

  create_table "document_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_document_categories_on_slug", unique: true
  end

  create_table "document_versions", force: :cascade do |t|
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.text "change_summary"
    t.datetime "created_at", null: false
    t.integer "document_id", null: false
    t.datetime "released_at"
    t.string "status", default: "draft"
    t.datetime "updated_at", null: false
    t.integer "uploaded_by_id"
    t.string "version", null: false
    t.index ["approved_by_id"], name: "index_document_versions_on_approved_by_id"
    t.index ["document_id", "version"], name: "index_document_versions_on_document_id_and_version", unique: true
    t.index ["document_id"], name: "index_document_versions_on_document_id"
    t.index ["status"], name: "index_document_versions_on_status"
    t.index ["uploaded_by_id"], name: "index_document_versions_on_uploaded_by_id"
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "current_version", default: "0.1"
    t.text "description"
    t.integer "design_drawing_id"
    t.string "doc_number", null: false
    t.string "doc_type", null: false
    t.integer "product_id"
    t.string "status", default: "draft"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
    t.index ["design_drawing_id"], name: "index_documents_on_design_drawing_id"
    t.index ["doc_number"], name: "index_documents_on_doc_number", unique: true
    t.index ["doc_type"], name: "index_documents_on_doc_type"
    t.index ["product_id"], name: "index_documents_on_product_id"
    t.index ["status"], name: "index_documents_on_status"
  end

  create_table "drawing_approvals", force: :cascade do |t|
    t.integer "approver_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "design_drawing_id", null: false
    t.integer "drawing_version_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_drawing_approvals_on_approver_id"
    t.index ["design_drawing_id"], name: "index_drawing_approvals_on_design_drawing_id"
    t.index ["drawing_version_id"], name: "index_drawing_approvals_on_drawing_version_id"
    t.index ["status"], name: "index_drawing_approvals_on_status"
  end

  create_table "drawing_versions", force: :cascade do |t|
    t.text "change_log"
    t.datetime "created_at", null: false
    t.integer "design_drawing_id", null: false
    t.integer "file_size"
    t.datetime "updated_at", null: false
    t.integer "uploaded_by_id", null: false
    t.string "version_label"
    t.string "version_number"
    t.string "version_type", default: "draft"
    t.index ["design_drawing_id"], name: "index_drawing_versions_on_design_drawing_id"
    t.index ["uploaded_by_id"], name: "index_drawing_versions_on_uploaded_by_id"
    t.index ["version_label"], name: "index_drawing_versions_on_version_label"
    t.index ["version_number"], name: "index_drawing_versions_on_version_number"
    t.index ["version_type"], name: "index_drawing_versions_on_version_type"
  end

  create_table "factories", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "province"
    t.text "remarks"
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id", "name"], name: "index_factories_on_supplier_id_and_name", unique: true
    t.index ["supplier_id"], name: "index_factories_on_supplier_id"
  end

  create_table "guide_categories", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "sort_order", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_guide_categories_on_slug", unique: true
  end

  create_table "guides", force: :cascade do |t|
    t.integer "author_id"
    t.text "content_html"
    t.text "content_md", null: false
    t.datetime "created_at", null: false
    t.integer "guide_category_id"
    t.integer "product_id"
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.index ["author_id"], name: "index_guides_on_author_id"
    t.index ["guide_category_id"], name: "index_guides_on_guide_category_id"
    t.index ["product_id"], name: "index_guides_on_product_id"
    t.index ["published_at"], name: "index_guides_on_published_at"
    t.index ["slug"], name: "index_guides_on_slug", unique: true
    t.index ["status"], name: "index_guides_on_status"
  end

  create_table "inspection_reports", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "inspection_id", null: false
    t.string "material_composition"
    t.text "product_remarks"
    t.string "size_range"
    t.text "size_table"
    t.string "status", default: "draft"
    t.string "style_description"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["inspection_id"], name: "index_inspection_reports_on_inspection_id", unique: true
  end

  create_table "inspection_request_items", force: :cascade do |t|
    t.integer "accept_qty"
    t.string "aql_level", default: "2.5", null: false
    t.string "code_letter"
    t.datetime "created_at", null: false
    t.string "inspection_level", default: "II", null: false
    t.integer "inspection_request_id", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.integer "reject_qty"
    t.integer "sample_size"
    t.string "style_number", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_request_id"], name: "index_inspection_request_items_on_inspection_request_id"
    t.index ["order_number"], name: "index_inspection_request_items_on_order_number"
  end

  create_table "inspection_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.integer "factory_id"
    t.string "factory_name"
    t.integer "inspection_id"
    t.string "inspection_type"
    t.string "order_number", null: false
    t.integer "product_id"
    t.text "ps_comments"
    t.integer "quantity", null: false
    t.text "remarks"
    t.date "requested_date", null: false
    t.string "result"
    t.string "status", default: "pending", null: false
    t.string "style_number", null: false
    t.integer "supplier_id", null: false
    t.string "supplier_name"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_inspection_requests_on_created_by_id"
    t.index ["factory_id"], name: "index_inspection_requests_on_factory_id"
    t.index ["inspection_id"], name: "index_inspection_requests_on_inspection_id"
    t.index ["order_number"], name: "index_inspection_requests_on_order_number"
    t.index ["product_id"], name: "index_inspection_requests_on_product_id"
    t.index ["status"], name: "index_inspection_requests_on_status"
    t.index ["supplier_id"], name: "index_inspection_requests_on_supplier_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.string "buyer"
    t.string "chemical_test"
    t.string "city"
    t.string "color"
    t.text "comments"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "etd"
    t.string "fabric_name"
    t.integer "factory_id"
    t.string "factory_name"
    t.date "inspection_date", null: false
    t.integer "inspection_request_id"
    t.string "inspection_type"
    t.integer "major_defects", default: 0
    t.integer "minor_defects", default: 0
    t.string "order_no", null: false
    t.integer "order_quantity"
    t.string "physical_test"
    t.integer "product_id"
    t.string "province"
    t.text "ps_comments"
    t.string "qc_name"
    t.integer "qty_rejected", default: 0
    t.string "reference_no", null: false
    t.date "requested_date"
    t.string "result"
    t.string "rfid_checking"
    t.string "set_name"
    t.integer "shipment_quantity"
    t.string "supplier_category"
    t.integer "supplier_id"
    t.string "supplier_name"
    t.string "transport"
    t.datetime "updated_at", null: false
    t.integer "week"
    t.index ["factory_id"], name: "index_inspections_on_factory_id"
    t.index ["inspection_date"], name: "index_inspections_on_inspection_date"
    t.index ["inspection_request_id"], name: "index_inspections_on_inspection_request_id"
    t.index ["order_no"], name: "index_inspections_on_order_no"
    t.index ["product_id"], name: "index_inspections_on_product_id"
    t.index ["reference_no"], name: "index_inspections_on_reference_no"
    t.index ["supplier_category"], name: "index_inspections_on_supplier_category"
    t.index ["supplier_id"], name: "index_inspections_on_supplier_id"
  end

  create_table "lifecycle_histories", force: :cascade do |t|
    t.integer "changed_by_id"
    t.datetime "created_at", null: false
    t.string "from_state"
    t.integer "product_id", null: false
    t.text "remark"
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_by_id"], name: "index_lifecycle_histories_on_changed_by_id"
    t.index ["product_id"], name: "index_lifecycle_histories_on_product_id"
  end

  create_table "material_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "CNY", null: false
    t.date "effective_date", null: false
    t.integer "material_id", null: false
    t.decimal "price_per_unit", precision: 12, scale: 4, null: false
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["effective_date"], name: "index_material_prices_on_effective_date"
    t.index ["material_id", "effective_date"], name: "index_material_prices_unique", unique: true
    t.index ["material_id"], name: "index_material_prices_on_material_id"
  end

  create_table "materials", force: :cascade do |t|
    t.integer "case_material_category_id"
    t.string "code", limit: 50, null: false
    t.datetime "created_at", null: false
    t.decimal "density", precision: 10, scale: 4
    t.text "description"
    t.string "kind", default: "metal", null: false
    t.string "name", limit: 100, null: false
    t.string "unit", default: "g", null: false
    t.datetime "updated_at", null: false
    t.index ["case_material_category_id"], name: "index_materials_on_case_material_category_id"
    t.index ["code"], name: "index_materials_on_code", unique: true
    t.index ["kind"], name: "index_materials_on_kind"
  end

  create_table "price_rules", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.date "effective_from"
    t.date "effective_to"
    t.decimal "labor_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "markup_rate", precision: 6, scale: 4, default: "1.0", null: false
    t.integer "material_id"
    t.string "name", limit: 100, null: false
    t.text "remark"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_price_rules_on_active"
    t.index ["category_id"], name: "index_price_rules_on_category_id"
    t.index ["material_id"], name: "index_price_rules_on_material_id"
  end

  create_table "product_boms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.integer "design_drawing_id"
    t.integer "design_project_id", null: false
    t.string "name", null: false
    t.integer "product_id"
    t.string "revision", default: "A"
    t.string "status", default: "draft"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_product_boms_on_created_by_id"
    t.index ["design_drawing_id"], name: "index_product_boms_on_design_drawing_id"
    t.index ["design_project_id"], name: "index_product_boms_on_design_project_id"
    t.index ["product_id"], name: "index_product_boms_on_product_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "image", null: false
    t.boolean "is_cover", default: false, null: false
    t.integer "position", default: 0
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "is_cover"], name: "index_product_images_on_product_id_and_is_cover", unique: true, where: "is_cover = true"
    t.index ["product_id", "position"], name: "index_product_images_on_product_id_and_position"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.decimal "base_weight", precision: 10, scale: 4
    t.integer "category_id", null: false
    t.integer "color_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "design_drawing_id"
    t.string "lifecycle_state", default: "concept", null: false
    t.datetime "lifecycle_updated_at"
    t.integer "main_material_id"
    t.integer "movement_category_id"
    t.string "name", limit: 255, null: false
    t.string "plating_color"
    t.string "product_code", limit: 50, null: false
    t.string "status", default: "draft", null: false
    t.integer "strap_category_id"
    t.integer "target_group_category_id"
    t.string "theme"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["color_id"], name: "index_products_on_color_id"
    t.index ["design_drawing_id"], name: "index_products_on_design_drawing_id"
    t.index ["main_material_id"], name: "index_products_on_main_material_id"
    t.index ["movement_category_id"], name: "index_products_on_movement_category_id"
    t.index ["product_code"], name: "index_products_on_product_code", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.index ["strap_category_id"], name: "index_products_on_strap_category_id"
    t.index ["target_group_category_id"], name: "index_products_on_target_group_category_id"
    t.index ["theme"], name: "index_products_on_theme"
  end

  create_table "serial_numbers", force: :cascade do |t|
    t.integer "batch_id"
    t.string "certificate_no", limit: 100
    t.string "code", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "sold_at"
    t.string "status", default: "in_stock", null: false
    t.datetime "updated_at", null: false
    t.integer "variant_id", null: false
    t.index ["batch_id"], name: "index_serial_numbers_on_batch_id"
    t.index ["certificate_no"], name: "index_serial_numbers_on_certificate_no"
    t.index ["code"], name: "index_serial_numbers_on_code", unique: true
    t.index ["status"], name: "index_serial_numbers_on_status"
    t.index ["variant_id"], name: "index_serial_numbers_on_variant_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "address", limit: 300
    t.string "bank_account", limit: 50
    t.string "bank_name", limit: 100
    t.string "category", limit: 100
    t.string "code", limit: 50, null: false
    t.string "contact_person", limit: 50
    t.datetime "created_at", null: false
    t.string "email", limit: 100
    t.string "level", default: "b"
    t.string "name", limit: 200, null: false
    t.string "phone", limit: 50
    t.text "remark"
    t.string "short_name", limit: 100
    t.string "status", default: "active"
    t.string "supplier_type", default: "parts"
    t.string "tax_number", limit: 50
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_suppliers_on_code", unique: true
    t.index ["status"], name: "index_suppliers_on_status"
    t.index ["supplier_type"], name: "index_suppliers_on_supplier_type"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "supplier_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["supplier_id"], name: "index_users_on_supplier_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "color", limit: 50
    t.datetime "created_at", null: false
    t.text "description"
    t.string "gemstone", limit: 50
    t.integer "material_id"
    t.integer "product_id", null: false
    t.string "size", limit: 50
    t.string "sku_code", limit: 50, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 4
    t.index ["material_id"], name: "index_variants_on_material_id"
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku_code"], name: "index_variants_on_sku_code", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "batches", "products"
  add_foreign_key "batches", "variants"
  add_foreign_key "bom_items", "bom_items", column: "parent_id"
  add_foreign_key "bom_items", "design_drawings"
  add_foreign_key "bom_items", "product_boms"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "design_drawings", "design_projects"
  add_foreign_key "design_drawings", "users", column: "created_by_id"
  add_foreign_key "design_projects", "users", column: "created_by_id"
  add_foreign_key "document_versions", "documents"
  add_foreign_key "document_versions", "users", column: "approved_by_id"
  add_foreign_key "document_versions", "users", column: "uploaded_by_id"
  add_foreign_key "documents", "design_drawings"
  add_foreign_key "documents", "products"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "drawing_approvals", "design_drawings"
  add_foreign_key "drawing_approvals", "drawing_versions"
  add_foreign_key "drawing_approvals", "users", column: "approver_id"
  add_foreign_key "drawing_versions", "design_drawings"
  add_foreign_key "drawing_versions", "users", column: "uploaded_by_id"
  add_foreign_key "factories", "suppliers"
  add_foreign_key "guides", "guide_categories"
  add_foreign_key "guides", "products"
  add_foreign_key "guides", "users", column: "author_id"
  add_foreign_key "inspection_reports", "inspections"
  add_foreign_key "inspection_request_items", "inspection_requests"
  add_foreign_key "inspection_requests", "factories"
  add_foreign_key "inspection_requests", "products"
  add_foreign_key "inspection_requests", "suppliers"
  add_foreign_key "inspection_requests", "users", column: "created_by_id"
  add_foreign_key "inspections", "factories"
  add_foreign_key "inspections", "inspection_requests"
  add_foreign_key "inspections", "products"
  add_foreign_key "inspections", "suppliers"
  add_foreign_key "lifecycle_histories", "products"
  add_foreign_key "lifecycle_histories", "users", column: "changed_by_id"
  add_foreign_key "material_prices", "materials"
  add_foreign_key "materials", "categories", column: "case_material_category_id"
  add_foreign_key "price_rules", "categories"
  add_foreign_key "price_rules", "materials"
  add_foreign_key "product_boms", "design_drawings"
  add_foreign_key "product_boms", "design_projects"
  add_foreign_key "product_boms", "products"
  add_foreign_key "product_boms", "users", column: "created_by_id"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "categories", column: "movement_category_id"
  add_foreign_key "products", "categories", column: "strap_category_id"
  add_foreign_key "products", "categories", column: "target_group_category_id"
  add_foreign_key "products", "design_drawings"
  add_foreign_key "products", "materials", column: "main_material_id"
  add_foreign_key "serial_numbers", "batches"
  add_foreign_key "serial_numbers", "variants"
  add_foreign_key "users", "suppliers"
  add_foreign_key "variants", "materials"
  add_foreign_key "variants", "products"
end
