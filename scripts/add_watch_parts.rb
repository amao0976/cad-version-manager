# Adds watch parts as BOM items for the gold watch product's BOM
# Run with: rails runner scripts/add_watch_parts.rb

puts "=== 查找金表产品及其BOM ==="

gold_watch = Product.find_by('name LIKE ?', '%金表%')
if gold_watch.nil?
  puts "未找到产品 '金表'，列出所有产品："
  Product.all.each { |p| puts "  ID=#{p.id} | 名称=#{p.name} | 编码=#{p.product_code}" }
else
  puts "找到产品: #{gold_watch.name} (ID=#{gold_watch.id})"

# 找到金表的BOM，没有则创建
bom = ProductBom.find_or_create_by!(product: gold_watch) do |b|
  project = DesignProject.first
  b.name = "#{gold_watch.name} BOM"
  b.revision = 'A'
  b.status = 'draft'
  b.description = '金表物料清单（参考手表标准零件结构）'
  b.design_project = project
  b.created_by = User.first
end
puts "使用 BOM: #{bom.name} (ID=#{bom.id}, 版本=#{bom.revision})"

# 清空旧物料项（避免重复）
bom.bom_items.destroy_all
puts "已清空旧物料项"

# 手表标准零件清单（参考网上资料整理）
# 结构：机芯、表壳组件、表盘组件、表带组件、包装
watch_parts = [
  # [part_number, part_name, material, specification, quantity, unit, weight, source, level]
  # 一级：机芯组件
  ['MV-001', '机芯组件', '瑞士机芯', 'ETA 2824-2 自动机械机芯', 1, '套', 12.5000, 'purchased', 1],
  # 一级：表壳组件
  ['CS-001', '表壳组件', '316L不锈钢+包金', '42mm 圆形', 1, '套', 25.0000, 'outsourced', 1],
  # 二级：表壳子件
  ['CS-001-01', '表壳主体', '316L不锈钢包18K金', '壳胚42mm', 1, '件', 15.0000, 'outsourced', 2],
  ['CS-001-02', '底盖', '316L不锈钢', '旋入式底盖', 1, '件', 5.0000, 'outsourced', 2],
  ['CS-001-03', '表玻璃', '蓝宝石水晶', '双面凸面防眩处理', 1, '件', 3.0000, 'purchased', 2],
  ['CS-001-04', '把的（表冠）', '316L不锈钢包金', '旋入式防水表冠', 1, '件', 0.8000, 'purchased', 2],
  ['CS-001-05', '防水胶圈', '丁腈橡胶', '底盖+表冠胶圈', 2, '件', 0.2000, 'purchased', 2],
  ['CS-001-06', '表圈', '18K金', '固定圈口', 1, '件', 4.5000, 'outsourced', 2],
  # 一级：表盘组件
  ['DL-001', '表盘组件', '黄铜+电镀', '白色字面', 1, '套', 3.0000, 'outsourced', 1],
  # 二级：表盘子件
  ['DL-001-01', '表盘（字面）', '黄铜', '直径38mm 喷字面', 1, '件', 2.0000, 'outsourced', 2],
  ['DL-001-02', '指针', '铝合金', '时分秒三针', 1, '套', 0.5000, 'purchased', 2],
  ['DL-001-03', '时标', '18K金', '条形钉', 12, '件', 0.4000, 'outsourced', 2],
  # 一级：表带组件
  ['BD-001', '表带组件', '316L不锈钢包金', '20mm表带', 1, '套', 35.0000, 'outsourced', 1],
  # 二级：表带子件
  ['BD-001-01', '表带（链节）', '316L不锈钢包18K金', '20mm 实心链节', 1, '条', 30.0000, 'outsourced', 2],
  ['BD-001-02', '表扣', '316L不锈钢包金', '蝴蝶折叠扣', 1, '件', 5.0000, 'purchased', 2],
  ['BD-001-03', '生耳（表带芯杆）', '不锈钢', '20mm 弹簧杆', 2, '件', 0.3000, 'purchased', 2],
  # 一级：包装物料
  ['PK-001', '包装物料', '纸+绒布', '礼盒套装', 1, '套', 200.0000, 'purchased', 1],
  # 二级：包装子件
  ['PK-001-01', '表盒', '硬纸板+绒布', '方形礼盒', 1, '件', 150.0000, 'purchased', 2],
  ['PK-001-02', '保修卡', '铜版纸', '产品保修卡', 1, '张', 5.0000, 'purchased', 2],
  ['PK-001-03', '说明书', '铜版纸', '产品说明书', 1, '本', 10.0000, 'purchased', 2],
  ['PK-001-04', '合格证', '铜版纸', '产品合格证', 1, '张', 5.0000, 'purchased', 2],
]

# 父项映射：part_number => BomItem 记录
parents = {}

watch_parts.each do |row|
  part_number, part_name, material, specification, quantity, unit, weight, source, level = row

  parent_id = nil
  # 二级零件查找父项：通过 part_number 前缀匹配
  if level == 2
    parent_prefix = part_number.split('-')[0] + '-001' # 如 CS-001-01 -> CS-001
    parent_id = parents[parent_prefix]
  end

  item = BomItem.create!(
    product_bom: bom,
    part_number: part_number,
    part_name: part_name,
    material: material,
    specification: specification,
    quantity: quantity,
    unit: unit,
    weight: weight,
    source: source,
    level: level,
    parent_id: parent_id
  )

  # 只记录一级零件作为父项
  parents[part_number] = item.id if level == 1
  puts "  已添加: [L#{level}] #{part_number} #{part_name} (#{quantity}#{unit})"
end

puts ""
puts "=== 完成 ==="
puts "BOM: #{bom.name} 共 #{bom.bom_items.count} 个物料项"
puts "其中一级零件 #{bom.bom_items.where(level: 1).count} 个，二级零件 #{bom.bom_items.where(level: 2).count} 个"
end
