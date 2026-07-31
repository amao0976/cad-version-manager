# 验货管理示例数据
# 前提：产品 WATCH001 (ID:1, 量产状态)、供应商 SUP001 (ID:1)、用户已存在

product = Product.find_by(product_code: 'WATCH001')
supplier = Supplier.find_by(code: 'SUP001')
admin_user = User.find_by(email: 'admin@example.com')

return unless product && supplier && admin_user

# 清理已有的示例数据（避免重复）
Inspection::Report.delete_all
Inspection::Record.delete_all
Inspection::RequestItem.delete_all
Inspection::Request.delete_all

puts "开始创建验货管理示例数据..."

# ============================================================
# 验货申请 1：首件检查 - 已完成
# ============================================================
req1 = Inspection::Request.new(
  product: product,
  supplier: supplier,
  created_by: admin_user,
  requested_date: Date.today - 14,
  inspection_type: '首件检查',
  status: 'completed',
  result: 'PASS',
  order_number: 'PO-2026-0001',
  style_number: 'W001-A',
  quantity: 800,
  remarks: '首件样品确认，尺寸和外观符合要求',
  ps_comments: '供应商提供了完整的首件检测报告'
)
req1.save!(validate: false)

Inspection::RequestItem.create!(inspection_request: req1, order_number: 'PO-2026-0001', style_number: 'W001-A', quantity: 500, inspection_level: 'II', aql_level: '2.5')
Inspection::RequestItem.create!(inspection_request: req1, order_number: 'PO-2026-0001', style_number: 'W001-B', quantity: 300, inspection_level: 'II', aql_level: '2.5')

# 对应的验货记录
record1 = Inspection::Record.create!(
  product: product,
  supplier: supplier,
  inspection_request: req1,
  inspection_date: Date.today - 12,
  order_no: 'PO-2026-0001',
  reference_no: 'INS-2026-0001',
  order_quantity: 800,
  shipment_quantity: 800,
  requested_date: Date.today - 14,
  inspection_type: '首件检查',
  buyer: '采购部',
  set_name: '手表套装',
  fabric_name: '不锈钢表壳',
  color: '银色',
  qc_name: '张质检',
  major_defects: 0,
  minor_defects: 2,
  qty_rejected: 0,
  result: 'pass',
  rfid_checking: '通过',
  chemical_test: '通过',
  physical_test: '通过',
  transport: '海运',
  etd: (Date.today + 20).to_s,
  comments: '首件检查通过，小缺陷已记录并要求供应商改进',
  ps_comments: '建议批量生产时加强外观检验'
)

# 验货报告
Inspection::Report.create!(
  inspection_record: record1,
  status: 'completed',
  style_description: '男款商务手表，316L不锈钢表壳',
  color: '银色',
  material_composition: '316L不锈钢 + 蓝宝石玻璃',
  size_range: '40mm',
  size_table: {
    'columns' => ['40mm'],
    'rows' => [
      { 'measurement_point' => '表壳外径', 'tolerance' => '0.2', 'values' => { '40mm' => { 'nominal' => '40.0', 'actual' => '40.1' } } },
      { 'measurement_point' => '表壳厚度', 'tolerance' => '0.1', 'values' => { '40mm' => { 'nominal' => '9.5', 'actual' => '9.6' } } },
      { 'measurement_point' => '表带宽度', 'tolerance' => '0.2', 'values' => { '40mm' => { 'nominal' => '20.0', 'actual' => '20.0' } } }
    ]
  },
  summary: '首件检查合格，所有关键尺寸在公差范围内，外观无重大缺陷',
  product_remarks: '建议批量生产时注意表壳抛光一致性'
)

req1.update_columns(inspection_id: record1.id)
puts "  [1/5] 验货申请1 (首件检查-已完成) + 验货记录 + 验货报告 创建成功"

# ============================================================
# 验货申请 2：中期检查 - 已排期
# ============================================================
req2 = Inspection::Request.new(
  product: product,
  supplier: supplier,
  created_by: admin_user,
  requested_date: Date.today - 3,
  inspection_type: '中期检查',
  status: 'scheduled',
  order_number: 'PO-2026-0002',
  style_number: 'W001-A',
  quantity: 2000,
  remarks: '批量生产中期验货，检查生产质量稳定性',
  ps_comments: '已与供应商确认验货时间'
)
req2.save!(validate: false)

Inspection::RequestItem.create!(inspection_request: req2, order_number: 'PO-2026-0002', style_number: 'W001-A', quantity: 2000, inspection_level: 'II', aql_level: '2.5')

puts "  [2/5] 验货申请2 (中期检查-已排期) 创建成功"

# ============================================================
# 验货申请 3：尾期检查 - 待处理
# ============================================================
req3 = Inspection::Request.new(
  product: product,
  supplier: supplier,
  created_by: admin_user,
  requested_date: Date.today + 5,
  inspection_type: '尾期检查',
  status: 'pending',
  order_number: 'PO-2026-0002',
  style_number: 'W001-A',
  quantity: 3500,
  remarks: '订单完成后的尾期验货，确认出货质量',
  ps_comments: '等待中期验货结果后确认排期'
)
req3.save!(validate: false)

Inspection::RequestItem.create!(inspection_request: req3, order_number: 'PO-2026-0002', style_number: 'W001-A', quantity: 2000, inspection_level: 'II', aql_level: '2.5')
Inspection::RequestItem.create!(inspection_request: req3, order_number: 'PO-2026-0002', style_number: 'W001-B', quantity: 1500, inspection_level: 'II', aql_level: '4.0')

puts "  [3/5] 验货申请3 (尾期检查-待处理) 创建成功"

# ============================================================
# 验货申请 4：过程检查 - 已完成（不合格）
# ============================================================
req4 = Inspection::Request.new(
  product: product,
  supplier: supplier,
  created_by: admin_user,
  requested_date: Date.today - 21,
  inspection_type: '过程检查',
  status: 'completed',
  result: 'FAIL',
  order_number: 'PO-2026-0003',
  style_number: 'W001-C',
  quantity: 1000,
  remarks: '生产过程抽检发现防水测试不合格',
  ps_comments: '要求供应商整改防水工艺后重新送检'
)
req4.save!(validate: false)

Inspection::RequestItem.create!(inspection_request: req4, order_number: 'PO-2026-0003', style_number: 'W001-C', quantity: 1000, inspection_level: 'I', aql_level: '2.5')

# 对应的验货记录（不合格）
record4 = Inspection::Record.create!(
  product: product,
  supplier: supplier,
  inspection_request: req4,
  inspection_date: Date.today - 19,
  order_no: 'PO-2026-0003',
  reference_no: 'INS-2026-0002',
  order_quantity: 1000,
  shipment_quantity: 1000,
  requested_date: Date.today - 21,
  inspection_type: '过程检查',
  buyer: '采购部',
  set_name: '手表套装',
  fabric_name: '不锈钢表壳',
  color: '枪色',
  qc_name: '李质检',
  major_defects: 5,
  minor_defects: 12,
  qty_rejected: 30,
  result: 'fail',
  rfid_checking: '通过',
  chemical_test: '通过',
  physical_test: '不通过',
  transport: '空运',
  etd: (Date.today + 15).to_s,
  comments: '防水测试未通过，5块手表进水；表盘有轻微划痕',
  ps_comments: '已要求供应商暂停出货，整改后安排重新验货'
)

# 验货报告
Inspection::Report.create!(
  inspection_record: record4,
  status: 'completed',
  style_description: '男款运动手表，316L不锈钢表壳，枪色PVD镀膜',
  color: '枪色',
  material_composition: '316L不锈钢 + 矿物玻璃',
  size_range: '42mm',
  size_table: {
    'columns' => ['42mm'],
    'rows' => [
      { 'measurement_point' => '表壳外径', 'tolerance' => '0.2', 'values' => { '42mm' => { 'nominal' => '42.0', 'actual' => '42.1' } } },
      { 'measurement_point' => '表壳厚度', 'tolerance' => '0.1', 'values' => { '42mm' => { 'nominal' => '12.0', 'actual' => '12.2' } } },
      { 'measurement_point' => '防水深度', 'tolerance' => '0', 'values' => { '42mm' => { 'nominal' => '50M', 'actual' => '30M' } } }
    ]
  },
  summary: '过程检查不合格，防水性能未达标，需整改后重新验货',
  product_remarks: '防水圈装配工艺需改进，PVD镀膜颜色一致性需加强'
)

req4.update_columns(inspection_id: record4.id)
puts "  [4/5] 验货申请4 (过程检查-不合格) + 验货记录 + 验货报告 创建成功"

# ============================================================
# 验货申请 5：中期检查 - 已取消
# ============================================================
req5 = Inspection::Request.new(
  product: product,
  supplier: supplier,
  created_by: admin_user,
  requested_date: Date.today - 10,
  inspection_type: '中期检查',
  status: 'cancelled',
  order_number: 'PO-2026-0004',
  style_number: 'W001-A',
  quantity: 800,
  remarks: '订单变更，取消此次验货',
  ps_comments: '客户调整订单数量，后续重新申请'
)
req5.save!(validate: false)

Inspection::RequestItem.create!(inspection_request: req5, order_number: 'PO-2026-0004', style_number: 'W001-A', quantity: 800, inspection_level: 'II', aql_level: '2.5')

puts "  [5/5] 验货申请5 (中期检查-已取消) 创建成功"

puts "\n验货管理示例数据创建完成！"
puts "  - 验货申请: #{Inspection::Request.count} 条"
puts "  - 验货申请明细: #{Inspection::RequestItem.count} 条"
puts "  - 验货记录: #{Inspection::Record.count} 条"
puts "  - 验货报告: #{Inspection::Report.count} 条"
