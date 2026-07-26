# 添加产品类别与供应商种子数据
# Run with: rails runner scripts/add_categories_and_suppliers.rb

puts "=== 1. 添加产品类别 ==="

# 一级分类
categories_data = [
  { code: 'WATCH',     name: '手表',     sort_order: 1, description: '各类手表产品：机械表、石英表、智能手表等' },
  { code: 'JEWELRY',   name: '首饰',     sort_order: 2, description: '贵金属首饰：项链、戒指、耳饰、手链等' },
  { code: 'HAIRACC',   name: '发饰',     sort_order: 3, description: '发卡、发簪、发箍、发圈等头发饰品' },
  { code: 'UMBRELLA',  name: '雨伞',     sort_order: 4, description: '各类雨伞、晴雨伞、遮阳伞等' }
]

# 各分类的二级子分类
sub_categories_data = {
  'WATCH' => [
    { code: 'WATCH-MECH',  name: '机械手表', sort_order: 1 },
    { code: 'WATCH-QUARTZ',name: '石英手表', sort_order: 2 },
    { code: 'WATCH-SMART', name: '智能手表', sort_order: 3 },
    { code: 'WATCH-LUX',   name: '名贵手表', sort_order: 4 }
  ],
  'JEWELRY' => [
    { code: 'JEW-NECK',  name: '项链',     sort_order: 1 },
    { code: 'JEW-RING',  name: '戒指',     sort_order: 2 },
    { code: 'JEW-EAR',   name: '耳饰',     sort_order: 3 },
    { code: 'JEW-BRACE', name: '手链/手镯', sort_order: 4 },
    { code: 'JEW-PEND',  name: '吊坠',     sort_order: 5 }
  ],
  'HAIRACC' => [
    { code: 'HAIR-CLIP', name: '发卡',     sort_order: 1 },
    { code: 'HAIR-PIN',  name: '发簪',     sort_order: 2 },
    { code: 'HAIR-BAND', name: '发箍',     sort_order: 3 },
    { code: 'HAIR-LOOP', name: '发圈',     sort_order: 4 }
  ],
  'UMBRELLA' => [
    { code: 'UMB-RAIN',  name: '雨伞',     sort_order: 1 },
    { code: 'UMB-SUN',   name: '遮阳伞',   sort_order: 2 },
    { code: 'UMB-FOLD',  name: '折叠伞',   sort_order: 3 },
    { code: 'UMB-LONG',  name: '长柄伞',   sort_order: 4 }
  ]
}

created_categories = {}
categories_data.each do |attrs|
  cat = Category.find_or_create_by!(code: attrs[:code]) do |c|
    c.name = attrs[:name]
    c.sort_order = attrs[:sort_order]
    c.description = attrs[:description]
  end
  created_categories[attrs[:code]] = cat
  puts "  一级分类: #{cat.name} (#{cat.code}, ID=#{cat.id})"
end

sub_categories_data.each do |parent_code, subs|
  parent = created_categories[parent_code]
  subs.each do |sub|
    child = Category.find_or_create_by!(code: sub[:code]) do |c|
      c.name = sub[:name]
      c.sort_order = sub[:sort_order]
      c.parent = parent
    end
    puts "    二级分类: #{child.name} (#{child.code})"
  end
end

puts ""
puts "=== 2. 添加供应商 ==="

suppliers_data = [
  # 手表相关供应商
  { name: '瑞士机芯供应商ETA公司', code: 'SUP-MV-001', short_name: 'ETA机芯',
    supplier_type: 'parts', level: 'a', status: 'active',
    contact_person: '张经理', phone: '021-5555-8888', email: 'sales@eta-china.com',
    address: '上海市浦东新区张江高科技园区',
    bank_name: '中国银行上海分行', bank_account: '6228 8800 1234 5678 901',
    tax_number: '91310000MA1FL1234X', remark: '瑞士ETA机芯中国区总代' },
  { name: '深圳精工表壳厂', code: 'SUP-CS-001', short_name: '精工表壳',
    supplier_type: 'outsourcing', level: 'a', status: 'active',
    contact_person: '李厂长', phone: '0755-8888-9999', email: 'order@jinggong-case.com',
    address: '广东省深圳市宝安区西乡街道',
    bank_name: '工商银行深圳分行', bank_account: '6222 0214 1234 5678 901',
    tax_number: '91440300MA5G1234Y', remark: '专业生产316L不锈钢表壳，可包金处理' },
  { name: '蓝宝石玻璃制品有限公司', code: 'SUP-GL-001', short_name: '蓝宝石玻璃',
    supplier_type: 'parts', level: 'a', status: 'active',
    contact_person: '王经理', phone: '0571-6666-7777', email: 'glass@sapphire-glass.com',
    address: '浙江省杭州市余杭区',
    bank_name: '建设银行杭州分行', bank_account: '6217 0014 1234 5678 901',
    tax_number: '91330100MA2H1234Z', remark: '蓝宝石水晶表玻璃专业制造商' },
  { name: '广州表带制造厂', code: 'SUP-BD-001', short_name: '广州表带',
    supplier_type: 'outsourcing', level: 'b', status: 'active',
    contact_person: '陈先生', phone: '020-3333-4444', email: 'bd@guangzhou-strap.com',
    address: '广东省广州市白云区',
    bank_name: '农业银行广州分行', bank_account: '6228 4800 1234 5678 901',
    tax_number: '91440100MA5U1234A', remark: '不锈钢/真皮表带制造商' },

  # 首饰相关供应商
  { name: '周大福黄金供应商', code: 'SUP-AU-001', short_name: '周大福黄金',
    supplier_type: 'raw_material', level: 'a', status: 'active',
    contact_person: '黄经理', phone: '0755-2558-9999', email: 'gold@chowtaifook.com',
    address: '广东省深圳市罗湖区水贝珠宝产业园',
    bank_name: '招商银行深圳分行', bank_account: '6225 8800 1234 5678 901',
    tax_number: '91440300MA5G5678B', remark: 'Au999.9/Au750黄金原料供应商' },
  { name: '天然宝石批发商', code: 'SUP-GEM-001', short_name: '宝石批发',
    supplier_type: 'raw_material', level: 'b', status: 'active',
    contact_person: '林老板', phone: '0755-2567-1234', email: 'gem@gemstone-wholesale.com',
    address: '广东省深圳市罗湖区水贝一路',
    bank_name: '中国银行深圳分行', bank_account: '6217 6014 1234 5678 901',
    tax_number: '91440300MA5G9012C', remark: '钻石、红宝石、蓝宝石、翡翠等天然宝石' },

  # 发饰相关供应商
  { name: '义乌发饰制品厂', code: 'SUP-HAIR-001', short_name: '义乌发饰',
    supplier_type: 'outsourcing', level: 'b', status: 'active',
    contact_person: '吴经理', phone: '0579-8512-3456', email: 'hair@yiwu-hairacc.com',
    address: '浙江省义乌市国际商贸城',
    bank_name: '义乌农商银行', bank_account: '6228 0300 1234 5678 901',
    tax_number: '91330700MA29A1234D', remark: '各类金属/树脂/布艺发饰制造商' },

  # 雨伞相关供应商
  { name: '杭州天堂伞业', code: 'SUP-UMB-001', short_name: '天堂伞业',
    supplier_type: 'outsourcing', level: 'a', status: 'active',
    contact_person: '徐经理', phone: '0571-8888-1234', email: 'order@paradise-umbrella.com',
    address: '浙江省杭州市余杭区瓶窑镇',
    bank_name: '建设银行杭州分行', bank_account: '6217 0014 5678 9012 345',
    tax_number: '91330100MA2H5678E', remark: '中国知名雨伞制造商，OEM/ODM均可' },

  # 包装供应商
  { name: '东莞包装制品有限公司', code: 'SUP-PKG-001', short_name: '东莞包装',
    supplier_type: 'packaging', level: 'b', status: 'active',
    contact_person: '马经理', phone: '0769-2222-3333', email: 'box@dg-packaging.com',
    address: '广东省东莞市长安镇',
    bank_name: '工商银行东莞分行', bank_account: '6222 0214 5678 9012 345',
    tax_number: '91441900MA5W1234F', remark: '高端礼盒、说明书、保修卡印刷包装一体化' },

  # 物流服务商
  { name: '顺丰速运合作部', code: 'SUP-LOG-001', short_name: '顺丰',
    supplier_type: 'logistics', level: 'a', status: 'active',
    contact_person: '客户经理', phone: '95338', email: 'business@sf-express.com',
    address: '广东省深圳市福田区',
    bank_name: '招商银行深圳分行', bank_account: '6225 8800 5678 9012 345',
    tax_number: '91440300MA5G3456G', remark: '贵重物品保价物流服务' }
]

suppliers_data.each do |attrs|
  supplier = Supplier.find_or_create_by!(code: attrs[:code]) do |s|
    s.assign_attributes(attrs)
  end
  puts "  供应商: #{supplier.name} (#{supplier.code}) - #{supplier.display_type} - #{supplier.display_level}"
end

puts ""
puts "=== 完成 ==="
puts "产品分类总数: #{Category.count}（一级 #{Category.where(parent_id: nil).count} 个）"
puts "供应商总数: #{Supplier.count}"
puts ""
puts "供应商类型分布:"
Supplier.supplier_types.each do |k, v|
  count = Supplier.where(supplier_type: k).count
  puts "  #{v}: #{count} 家"
end
