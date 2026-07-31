# 手表分类种子数据
# 分类层级体系：
# L0: 手表（最顶端分类）
#   L1: 机芯类型（机械手表、石英手表、智能手表、光动能手表、人动电能手表）
#   L1: 表壳材质（属性分组）→ L2: 精钢、黄金、白金...
#   L1: 表带类型（属性分组）→ L2: 金属表带、皮质表带...
#   L1: 目标人群（属性分组）→ L2: 男表、女表...

puts "开始重构手表分类数据..."

# 清理旧的子分类（机械手表子分类等暂时不需要的）
old_sub_codes = %w[
  DRESS_MECHANICAL SPORTS_MECHANICAL DIVE_MECHANICAL PILOT_MECHANICAL
  CHRONOGRAPH_MECHANICAL LUXURY_MECHANICAL COMPLICATION_MECHANICAL
  FIELD_MECHANICAL TOURBILLON PERPETUAL_CALENDAR
  DRESS_QUARTZ SPORTS_QUARTZ DIVE_QUARTZ FASHION_QUARTZ DIGITAL_QUARTZ
  SPORTS_SMART BUSINESS_SMART LUXURY_SMART
  DRESS_SOLAR SPORTS_SOLAR
  DRESS_KINETIC SPORTS_KINETIC
]
Category.where(code: old_sub_codes).destroy_all

# ============================================================
# L0: 手表（最顶端分类）
# ============================================================
watch_root = Category.find_or_create_by!(code: 'WATCH') do |c|
  c.name = '手表'
  c.description = '手表产品顶级分类'
  c.sort_order = 1
end

# ============================================================
# L1: 机芯类型（直接挂在 L0 手表下）
# ============================================================
movements = [
  { code: 'MECHANICAL', name: '机械手表', description: '以机械式震荡器做调节的手表，以发条为动力来源。包括手动上链和自动上链两种类型。', sort_order: 1 },
  { code: 'QUARTZ', name: '石英手表', description: '以石英晶体振荡器驱动的手表，走时精度高，维护简单，是市场主流产品。', sort_order: 2 },
  { code: 'SMARTWATCH', name: '智能手表', description: '集成智能化功能的腕表，支持健康监测、运动追踪、消息通知等功能。', sort_order: 3 },
  { code: 'SOLAR', name: '光动能手表', description: '利用光能转化为电能驱动的手表，环保便捷，无需频繁更换电池。', sort_order: 4 },
  { code: 'KINETIC', name: '人动电能手表', description: '通过手腕运动驱动微型发电机为电池充电的石英手表，兼具机械表便利性和石英表高精度。', sort_order: 5 }
]

movements.each do |m|
  cat = Category.find_or_create_by!(code: m[:code]) do |c|
    c.name = m[:name]
    c.description = m[:description]
    c.sort_order = m[:sort_order]
  end
  # 确保挂在手表下
  cat.update(parent: watch_root, sort_order: m[:sort_order])
end

# ============================================================
# L1: 表壳材质（属性分组）→ L2: 具体材质选项
# ============================================================
parent_material = Category.find_or_create_by!(code: 'MATERIAL') do |c|
  c.name = '表壳材质'
  c.description = '按表壳材质分类，用于零件或配件建立时选取'
  c.sort_order = 6
end
parent_material.update(parent: watch_root)

material_options = [
  { code: 'STAINLESS_STEEL', name: '精钢', description: '最常见的表壳材质，耐用耐磨，性价比高，通常使用316L医用级不锈钢。', sort_order: 1 },
  { code: 'GOLD_YELLOW', name: '黄金', description: '传统奢华材质，18K金是最常用的黄金表壳材质。', sort_order: 2 },
  { code: 'GOLD_WHITE', name: '白金', description: '在黄金基础上镀铑，呈现银色光泽的18K金表壳。', sort_order: 3 },
  { code: 'GOLD_ROSE', name: '玫瑰金', description: '黄金中加入铜元素，呈现温暖红金色泽的18K金表壳。', sort_order: 4 },
  { code: 'PLATINUM', name: '铂金', description: '最稀有昂贵的贵金属表壳，天然银白光泽，以Pt950为标准。', sort_order: 5 },
  { code: 'TITANIUM', name: '钛金属', description: '轻便坚固、耐腐蚀、低致敏性，常用于运动表和高档表。', sort_order: 6 },
  { code: 'CERAMIC', name: '陶瓷', description: '高硬度、耐磨、轻便、光泽好，不易褪色或刮花。', sort_order: 7 },
  { code: 'CARBON', name: '碳纤维', description: '高科技材质，轻便坚固，具有独特的编织纹理外观。', sort_order: 8 },
  { code: 'BRONZE', name: '青铜', description: '复古风格材质，使用后会产生独特的包浆效果。', sort_order: 9 }
]

material_options.each do |sub|
  cat = Category.find_or_create_by!(code: sub[:code]) do |c|
    c.name = sub[:name]
    c.description = sub[:description]
    c.sort_order = sub[:sort_order]
  end
  cat.update(name: sub[:name], parent: parent_material, sort_order: sub[:sort_order], description: sub[:description])
end

# ============================================================
# L1: 表带类型（属性分组）→ L2: 具体表带选项
# ============================================================
parent_strap = Category.find_or_create_by!(code: 'STRAP') do |c|
  c.name = '表带类型'
  c.description = '按表带类型分类，用于手表产品建立时选取'
  c.sort_order = 7
end
parent_strap.update(parent: watch_root)

strap_options = [
  { code: 'METAL_BRACELET', name: '金属表带', description: '金属链节表带，可调节性强，适合正式场合和日常佩戴。', sort_order: 1 },
  { code: 'LEATHER_STRAP', name: '皮质表带', description: '柔软舒适，质感温润，需定期保养，适合商务和休闲场合。', sort_order: 2 },
  { code: 'RUBBER_STRAP', name: '橡胶表带', description: '防水防汗，轻盈灵活，运动性能出色。', sort_order: 3 },
  { code: 'NYLON_STRAP', name: '尼龙表带', description: '耐磨耐用，多为军用风格，适合户外和运动场合。', sort_order: 4 },
  { code: 'SILICONE_STRAP', name: '硅胶表带', description: '柔软亲肤，防水耐用，适合运动和智能手表。', sort_order: 5 },
  { code: 'CERAMIC_BRACELET', name: '陶瓷表带', description: '高科技陶瓷材质，光滑耐磨，外观时尚。', sort_order: 6 }
]

strap_options.each do |sub|
  cat = Category.find_or_create_by!(code: sub[:code]) do |c|
    c.name = sub[:name]
    c.description = sub[:description]
    c.sort_order = sub[:sort_order]
  end
  cat.update(name: sub[:name], parent: parent_strap, sort_order: sub[:sort_order], description: sub[:description])
end

# ============================================================
# L1: 目标人群（属性分组）→ L2: 具体人群选项
# ============================================================
parent_target = Category.find_or_create_by!(code: 'TARGET_GROUP') do |c|
  c.name = '目标人群'
  c.description = '按目标人群分类，用于手表产品建立时选取'
  c.sort_order = 8
end
parent_target.update(parent: watch_root)

target_options = [
  { code: 'MENS', name: '男表', description: '表径较大（38-46mm），设计硬朗，功能侧重实用性与计时性能。', sort_order: 1 },
  { code: 'WOMENS', name: '女表', description: '表径较小（20-34mm），注重细节装饰，风格柔美。', sort_order: 2 },
  { code: 'UNISEX', name: '中性表', description: '设计简约，表径适中（34-38mm），男女皆可佩戴。', sort_order: 3 },
  { code: 'CHILDREN', name: '儿童表', description: '安全材质，功能简单，适合儿童佩戴。', sort_order: 4 }
]

target_options.each do |sub|
  cat = Category.find_or_create_by!(code: sub[:code]) do |c|
    c.name = sub[:name]
    c.description = sub[:description]
    c.sort_order = sub[:sort_order]
  end
  cat.update(name: sub[:name], parent: parent_target, sort_order: sub[:sort_order], description: sub[:description])
end

# ============================================================
# 打印结果
# ============================================================
puts "手表分类数据重构完成！"
puts ""
puts "分类层级结构:"
puts "L0: #{watch_root.name} (#{watch_root.code})"
watch_root.children.order(:sort_order).each do |l1|
  l2_count = l1.children.count
  if l2_count > 0
    puts "  L1: #{l1.name} (#{l1.code}) → #{l2_count}个L2选项"
    l1.children.order(:sort_order).each do |l2|
      puts "    L2: #{l2.name} (#{l2.code})"
    end
  else
    puts "  L1: #{l1.name} (#{l1.code})"
  end
end
total = Category.count
puts ""
puts "总计: #{total} 个分类"
