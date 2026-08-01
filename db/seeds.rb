admin = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Admin User'
  user.role = 'admin'
end

manager = User.find_or_create_by(email: 'manager@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Manager User'
  user.role = 'manager'
end

engineer = User.find_or_create_by(email: 'engineer@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Engineer User'
  user.role = 'engineer'
end

project1 = DesignProject.find_or_create_by(name: 'NX 产品设计项目') do |p|
  p.description = '使用 Siemens NX 进行的产品设计项目'
  p.status = 'active'
  p.created_by = admin
end

project2 = DesignProject.find_or_create_by(name: 'Solid Edge 装配项目') do |p|
  p.description = '使用 Solid Edge 进行的装配体设计项目'
  p.status = 'active'
  p.created_by = manager
end

project3 = DesignProject.find_or_create_by(name: '精密零件加工项目') do |p|
  p.description = '高精度精密零件的设计与加工项目'
  p.status = 'active'
  p.created_by = engineer
end

drawing1 = DesignDrawing.find_or_create_by(name: '主壳体零件图') do |d|
  d.description = '产品主壳体的详细设计图纸'
  d.file_type = 'prt'
  d.design_project = project1
  d.created_by = admin
end

drawing2 = DesignDrawing.find_or_create_by(name: '端盖零件图') do |d|
  d.description = '端盖组件设计图纸'
  d.file_type = 'prt'
  d.design_project = project1
  d.created_by = engineer
end

drawing3 = DesignDrawing.find_or_create_by(name: '密封垫圈图') do |d|
  d.description = '标准密封垫圈设计图纸'
  d.file_type = 'dft'
  d.design_project = project1
  d.created_by = engineer
end

drawing4 = DesignDrawing.find_or_create_by(name: '轴承座零件图') do |d|
  d.description = '轴承座详细设计图纸'
  d.file_type = 'prt'
  d.design_project = project2
  d.created_by = manager
end

drawing5 = DesignDrawing.find_or_create_by(name: '传动轴零件图') do |d|
  d.description = '传动系统主轴设计图纸'
  d.file_type = 'prt'
  d.design_project = project2
  d.created_by = engineer
end

drawing6 = DesignDrawing.find_or_create_by(name: '螺栓连接件图') do |d|
  d.description = '标准螺栓连接件图纸'
  d.file_type = 'dft'
  d.design_project = project3
  d.created_by = engineer
end

drawing7 = DesignDrawing.find_or_create_by(name: '弹簧组件图') do |d|
  d.description = '弹簧组件设计图纸'
  d.file_type = 'step'
  d.design_project = project3
  d.created_by = engineer
end

drawing8 = DesignDrawing.find_or_create_by(name: '垫片零件图') do |d|
  d.description = '通用垫片设计图纸（可复用）'
  d.file_type = 'dft'
  d.design_project = project1
  d.created_by = engineer
end

bom1 = ProductBom.find_or_create_by(name: '产品A - 完整BOM') do |b|
  b.description = '产品A的完整物料清单'
  b.revision = 'A'
  b.status = 'approved'
  b.design_project = project1
  b.design_drawing = drawing1
  b.created_by = admin
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-001', part_name: '主壳体', level: 1) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '铝合金6061'
  item.specification = '150x100x80mm'
  item.weight = '1.5'
  item.source = 'in_house'
  item.design_drawing = drawing1
end

item_p002 = BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-002', part_name: '端盖组件', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '铝合金5052'
  item.specification = 'φ80x20mm'
  item.weight = '0.3'
  item.source = 'in_house'
  item.design_drawing = drawing2
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-003', part_name: '密封垫圈', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '丁腈橡胶'
  item.specification = 'φ80xφ65x3mm'
  item.weight = '0.02'
  item.source = 'purchased'
  item.design_drawing = drawing3
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-004', part_name: '螺栓M8x20', level: 1) do |item|
  item.quantity = 8
  item.unit = '个'
  item.material = '碳钢镀锌'
  item.specification = 'M8x20'
  item.weight = '0.05'
  item.source = 'purchased'
  item.design_drawing = drawing6
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-005', part_name: '弹簧压片', level: 1) do |item|
  item.quantity = 4
  item.unit = '件'
  item.material = '弹簧钢'
  item.specification = '30x15x1.5mm'
  item.weight = '0.01'
  item.source = 'in_house'
  item.design_drawing = drawing7
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-006', part_name: '平垫片', level: 1) do |item|
  item.quantity = 8
  item.unit = '个'
  item.material = '不锈钢304'
  item.specification = 'φ8'
  item.weight = '0.005'
  item.source = 'purchased'
  item.design_drawing = drawing8
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-002-01', part_name: '端盖本体', level: 2, parent: item_p002) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '铝合金5052'
  item.specification = 'φ80x15mm'
  item.weight = '0.25'
  item.source = 'in_house'
  item.design_drawing = drawing2
end

BomItem.find_or_create_by(product_bom: bom1, part_number: 'P-002-02', part_name: '密封圈槽', level: 2, parent: item_p002) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '丁腈橡胶'
  item.specification = 'φ75xφ68x2mm'
  item.weight = '0.01'
  item.source = 'outsourced'
  item.design_drawing = drawing3
end

bom2 = ProductBom.find_or_create_by(name: '产品B - 传动系统BOM') do |b|
  b.description = '产品B传动系统的物料清单'
  b.revision = 'A'
  b.status = 'approved'
  b.design_project = project2
  b.design_drawing = drawing5
  b.created_by = manager
end

BomItem.find_or_create_by(product_bom: bom2, part_number: 'P-007', part_name: '轴承座', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '铸铁HT250'
  item.specification = '120x80x60mm'
  item.weight = '3.5'
  item.source = 'in_house'
  item.design_drawing = drawing4
end

BomItem.find_or_create_by(product_bom: bom2, part_number: 'P-008', part_name: '传动轴', level: 1) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '45号钢'
  item.specification = 'φ40x300mm'
  item.weight = '2.8'
  item.source = 'in_house'
  item.design_drawing = drawing5
end

BomItem.find_or_create_by(product_bom: bom2, part_number: 'P-004', part_name: '螺栓M8x20', level: 1) do |item|
  item.quantity = 6
  item.unit = '个'
  item.material = '碳钢镀锌'
  item.specification = 'M8x20'
  item.weight = '0.05'
  item.source = 'purchased'
  item.design_drawing = drawing6
end

BomItem.find_or_create_by(product_bom: bom2, part_number: 'P-006', part_name: '平垫片', level: 1) do |item|
  item.quantity = 6
  item.unit = '个'
  item.material = '不锈钢304'
  item.specification = 'φ8'
  item.weight = '0.005'
  item.source = 'purchased'
  item.design_drawing = drawing8
end

BomItem.find_or_create_by(product_bom: bom2, part_number: 'P-009', part_name: '深沟球轴承', level: 1) do |item|
  item.quantity = 2
  item.unit = '个'
  item.material = '轴承钢'
  item.specification = '6208-ZZ'
  item.weight = '0.6'
  item.source = 'purchased'
end

bom3 = ProductBom.find_or_create_by(name: '产品C - 精密组件BOM') do |b|
  b.description = '产品C精密组件的物料清单'
  b.revision = 'A'
  b.status = 'draft'
  b.design_project = project3
  b.created_by = engineer
end

BomItem.find_or_create_by(product_bom: bom3, part_number: 'P-010', part_name: '精密齿轮', level: 1) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '20CrMnTi'
  item.specification = '模数2,齿数30'
  item.weight = '0.8'
  item.source = 'outsourced'
end

BomItem.find_or_create_by(product_bom: bom3, part_number: 'P-011', part_name: '精密轴套', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '铜合金'
  item.specification = 'φ30xφ25x40mm'
  item.weight = '0.2'
  item.source = 'outsourced'
end

BomItem.find_or_create_by(product_bom: bom3, part_number: 'P-006', part_name: '平垫片', level: 1) do |item|
  item.quantity = 4
  item.unit = '个'
  item.material = '不锈钢304'
  item.specification = 'φ8'
  item.weight = '0.005'
  item.source = 'purchased'
  item.design_drawing = drawing8
end

BomItem.find_or_create_by(product_bom: bom3, part_number: 'P-004', part_name: '螺栓M8x20', level: 1) do |item|
  item.quantity = 4
  item.unit = '个'
  item.material = '碳钢镀锌'
  item.specification = 'M8x20'
  item.weight = '0.05'
  item.source = 'purchased'
  item.design_drawing = drawing6
end

bom4 = ProductBom.find_or_create_by(name: '产品D - 外壳组件BOM') do |b|
  b.description = '产品D外壳组件的物料清单'
  b.revision = 'B'
  b.status = 'approved'
  b.design_project = project1
  b.design_drawing = drawing1
  b.created_by = admin
end

BomItem.find_or_create_by(product_bom: bom4, part_number: 'P-001', part_name: '主壳体', level: 1) do |item|
  item.quantity = 1
  item.unit = '件'
  item.material = '铝合金6061'
  item.specification = '180x120x100mm'
  item.weight = '2.2'
  item.source = 'in_house'
  item.design_drawing = drawing1
end

BomItem.find_or_create_by(product_bom: bom4, part_number: 'P-002', part_name: '端盖组件', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '铝合金5052'
  item.specification = 'φ100x25mm'
  item.weight = '0.45'
  item.source = 'in_house'
  item.design_drawing = drawing2
end

BomItem.find_or_create_by(product_bom: bom4, part_number: 'P-003', part_name: '密封垫圈', level: 1) do |item|
  item.quantity = 2
  item.unit = '件'
  item.material = '氟橡胶'
  item.specification = 'φ100xφ85x3mm'
  item.weight = '0.03'
  item.source = 'purchased'
  item.design_drawing = drawing3
end

BomItem.find_or_create_by(product_bom: bom4, part_number: 'P-006', part_name: '平垫片', level: 1) do |item|
  item.quantity = 12
  item.unit = '个'
  item.material = '不锈钢304'
  item.specification = 'φ8'
  item.weight = '0.005'
  item.source = 'purchased'
  item.design_drawing = drawing8
end

puts '数据库初始化完成！'
puts "管理员账号: admin@example.com / password123"
puts "经理账号: manager@example.com / password123"
puts "工程师账号: engineer@example.com / password123"
puts ""
puts "创建的项目:"
puts "  - #{project1.name}"
puts "  - #{project2.name}"
puts "  - #{project3.name}"
puts ""
puts "创建的图纸:"
puts "  - #{drawing1.name} (#{drawing1.file_type})"
puts "  - #{drawing2.name} (#{drawing2.file_type})"
puts "  - #{drawing3.name} (#{drawing3.file_type})"
puts "  - #{drawing4.name} (#{drawing4.file_type})"
puts "  - #{drawing5.name} (#{drawing5.file_type})"
puts "  - #{drawing6.name} (#{drawing6.file_type})"
puts "  - #{drawing7.name} (#{drawing7.file_type})"
puts "  - #{drawing8.name} (#{drawing8.file_type})"
puts ""
puts "创建的BOM:"
puts "  - #{bom1.name} (#{bom1.status})"
puts "  - #{bom2.name} (#{bom2.status})"
puts "  - #{bom3.name} (#{bom3.status})"
puts "  - #{bom4.name} (#{bom4.status})"
puts ""
puts "共用零件（跨BOM复用）:"
puts "  - P-004 螺栓M8x20 (产品A、产品B、产品C)"
puts "  - P-006 平垫片 (产品A、产品B、产品C、产品D)"
puts "  - P-002 端盖组件 (产品A、产品D)"
puts "  - P-003 密封垫圈 (产品A、产品D)"
puts "  - P-001 主壳体 (产品A、产品D)"

# ============================================================
# 验货管理种子数据
# ============================================================
puts "\n开始创建验货管理数据..."

# 加载手表分类种子数据
load(Rails.root.join('db', 'seeds_watch_categories.rb').to_s) rescue nil

# QC 用户
qc_user = User.find_or_create_by!(email: 'qc@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.name = 'QC检验员'
  u.role = 'qc'
end
puts "  QC账号: qc@example.com / password123"

# 供应商
supplier = Supplier.find_or_create_by!(code: 'SUP-001') do |s|
  s.name = '深圳精密钟表制造有限公司'
  s.short_name = '深圳精钟'
  s.supplier_type = 'outsourcing'
  s.status = 'active'
  s.level = 'a'
  s.contact_person = '张经理'
  s.phone = '13800138001'
  s.address = '深圳市宝安区钟表产业园'
end

supplier2 = Supplier.find_or_create_by!(code: 'SUP-002') do |s|
  s.name = '广州表壳配件厂'
  s.short_name = '广州表壳'
  s.supplier_type = 'parts'
  s.status = 'active'
  s.level = 'b'
  s.contact_person = '李厂长'
  s.phone = '13900139002'
  s.address = '广州市番禺区工业区'
end

# 产品（需要分类）
watch_category = Category.find_by(code: 'WATCH') || Category.find_or_create_by!(code: 'WATCH') do |c|
  c.name = '手表'
  c.sort_order = 1
end

product = Product.find_or_create_by!(product_code: 'W-CLASSIC-001') do |p|
  p.name = '经典商务机械表'
  p.category = watch_category
  p.status = 'published'
  p.lifecycle_state = 'production'
end

product2 = Product.find_or_create_by!(product_code: 'W-SPORT-001') do |p|
  p.name = '运动潜水石英表'
  p.category = watch_category
  p.status = 'published'
  p.lifecycle_state = 'production'
end

# === 验货申请 ===
# 1. 待处理 - 中期检查
req1 = Inspection::Request.find_or_create_by!(order_number: 'PO-2026-1001', style_number: 'W-CLASSIC-001') do |r|
  r.supplier = supplier
  r.product = product
  r.inspection_type = '中期检查'
  r.requested_date = Date.today + 5
  r.created_by = admin
  r.items.build(order_number: 'PO-2026-1001', style_number: 'W-CLASSIC-001', quantity: 5000, inspection_level: 'II', aql_level: '2.5')
  r.items.build(order_number: 'PO-2026-1001', style_number: 'W-CLASSIC-002', quantity: 3000, inspection_level: 'II', aql_level: '2.5')
end

# 2. 已排期 - 尾期检查
req2 = Inspection::Request.find_or_create_by!(order_number: 'PO-2026-1002', style_number: 'W-SPORT-001') do |r|
  r.supplier = supplier
  r.product = product2
  r.inspection_type = '尾期检查'
  r.requested_date = Date.today + 3
  r.created_by = admin
  r.items.build(order_number: 'PO-2026-1002', style_number: 'W-SPORT-001', quantity: 8000, inspection_level: 'II', aql_level: '2.5')
end
req2.schedule! unless req2.status == 'scheduled'

# 3. 已取消
req3 = Inspection::Request.find_or_create_by!(order_number: 'PO-2026-1003', style_number: 'W-LUXE-001') do |r|
  r.supplier = supplier2
  r.product = product
  r.inspection_type = '首件检查'
  r.requested_date = Date.today - 5
  r.created_by = admin
  r.items.build(order_number: 'PO-2026-1003', style_number: 'W-LUXE-001', quantity: 1000, inspection_level: 'I', aql_level: '1.5')
end
req3.cancel! unless req3.status == 'cancelled'

# 4. 待处理 - 过程检查
req4 = Inspection::Request.find_or_create_by!(order_number: 'PO-2026-1004', style_number: 'W-DIVE-001') do |r|
  r.supplier = supplier
  r.product = product2
  r.inspection_type = '过程检查'
  r.requested_date = Date.today + 7
  r.created_by = admin
  r.items.build(order_number: 'PO-2026-1004', style_number: 'W-DIVE-001', quantity: 2000, inspection_level: 'III', aql_level: '1.5')
end

# 5. 已排期 - 中期检查
req5 = Inspection::Request.find_or_create_by!(order_number: 'PO-2026-1005', style_number: 'W-CHRONO-001') do |r|
  r.supplier = supplier2
  r.product = product
  r.inspection_type = '中期检查'
  r.requested_date = Date.today + 2
  r.created_by = admin
  r.items.build(order_number: 'PO-2026-1005', style_number: 'W-CHRONO-001', quantity: 3500, inspection_level: 'II', aql_level: '2.5')
  r.items.build(order_number: 'PO-2026-1005', style_number: 'W-CHRONO-002', quantity: 2500, inspection_level: 'II', aql_level: '2.5')
end
req5.schedule! unless req5.status == 'scheduled'

puts "  验货申请: #{Inspection::Request.count} 条"

# === 验货记录 ===
# 1. 合格（关联已排期申请req2）
rec1 = Inspection::Record.find_or_create_by!(order_no: 'PO-2026-1002', inspection_date: Date.today - 2) do |r|
  r.inspection_request = req2
  r.supplier = supplier
  r.product = product2
  r.reference_no = 'W-SPORT-001'
  r.inspection_type = '尾期检查'
  r.order_quantity = 8000
  r.shipment_quantity = 8000
  r.major_defects = 2
  r.minor_defects = 5
  r.qty_rejected = 10
  r.result = 'pass'
  r.qc_name = 'QC检验员'
  r.comments = '产品质量良好，主要缺陷和次要缺陷均在AQL范围内。包装完整，标签正确。'
end

# 2. 不合格
rec2 = Inspection::Record.find_or_create_by!(order_no: 'PO-2026-0995', inspection_date: Date.today - 7) do |r|
  r.supplier = supplier
  r.product = product
  r.reference_no = 'W-CLASSIC-003'
  r.inspection_type = '中期检查'
  r.order_quantity = 5000
  r.shipment_quantity = 4500
  r.major_defects = 15
  r.minor_defects = 28
  r.qty_rejected = 120
  r.result = 'fail'
  r.qc_name = 'QC检验员'
  r.comments = '主要缺陷数超出AQL接受标准。发现表盘划痕较多，需要返工处理。建议整改后重新验货。'
end

# 3. 合格（无报告）
rec3 = Inspection::Record.find_or_create_by!(order_no: 'PO-2026-0988', inspection_date: Date.today - 1) do |r|
  r.supplier = supplier
  r.product = product2
  r.reference_no = 'W-DIVE-001'
  r.inspection_type = '过程检查'
  r.order_quantity = 3000
  r.shipment_quantity = 2800
  r.major_defects = 1
  r.minor_defects = 3
  r.qty_rejected = 5
  r.result = 'pass'
  r.qc_name = 'QC检验员'
  r.comments = '过程巡检合格，生产过程稳定。'
end

# 4. 不合格（无报告）
rec4 = Inspection::Record.find_or_create_by!(order_no: 'PO-2026-0990', inspection_date: Date.today - 3) do |r|
  r.supplier = supplier2
  r.product = product
  r.reference_no = 'W-CHRONO-001'
  r.inspection_type = '首件检查'
  r.order_quantity = 1500
  r.shipment_quantity = 1400
  r.major_defects = 8
  r.minor_defects = 12
  r.qty_rejected = 45
  r.result = 'fail'
  r.qc_name = 'QC检验员'
  r.comments = '首件检查不合格。表壳螺纹偏差超出公差，需调整夹具后重新生产首件。'
end

# 5. 待检验
rec5 = Inspection::Record.find_or_create_by!(order_no: 'PO-2026-1010', inspection_date: Date.today) do |r|
  r.supplier = supplier
  r.product = product2
  r.reference_no = 'W-SPORT-002'
  r.inspection_type = '中期检查'
  r.order_quantity = 6000
  r.shipment_quantity = 5500
  r.qc_name = ''
  r.comments = '验货进行中，等待QC判定结果。'
end

puts "  验货记录: #{Inspection::Record.count} 条"

# === 验货报告 ===
report1 = Inspection::Report.find_or_create_by!(inspection_record: rec1) do |r|
  r.status = 'draft'
  r.summary = '本次尾期检验结果合格，产品符合质量要求。抽样检验合格，包装和标签正确。'
end

report2 = Inspection::Report.find_or_create_by!(inspection_record: rec2) do |r|
  r.status = 'draft'
  r.summary = '本次中期检验结果不合格，主要缺陷超标，需返工处理。'
end

puts "  验货报告: #{Inspection::Report.count} 条"
puts "验货管理数据创建完成！"