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