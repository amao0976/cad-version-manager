#!/usr/bin/env ruby
# Encoding: UTF-8
# 批量添加常见材质数据

require_relative 'config/environment'

materials_data = [
  # ==================== 锌合金类 ====================
  { name: '锌合金 Zamak 3', code: 'ZN-ZAMAK3', kind: '锌合金', unit: 'kg', density: 6.6, description: '最常用的压铸锌合金，流动性好，适用于复杂形状零件，如五金件、玩具、装饰件等。' },
  { name: '锌合金 Zamak 5', code: 'ZN-ZAMAK5', kind: '锌合金', unit: 'kg', density: 6.7, description: '含铜量较高，硬度和强度优于Zamak3，耐磨性好。适用于需要耐磨的场合，如轴承、齿轮等。' },
  { name: '锌合金 Zamak 2', code: 'ZN-ZAMAK2', kind: '锌合金', unit: 'kg', density: 6.6, description: '高铝含量的锌合金，用于压铸，可热处理强化。' },
  { name: '锌合金 ZA-3', code: 'ZN-ZA3', kind: '锌合金', unit: 'kg', density: 5.9, description: '高铝锌合金，具有良好的耐磨性和抗振性，适用于轴承和滑块等。' },
  { name: '锌合金 ZA-8', code: 'ZN-ZA8', kind: '锌合金', unit: 'kg', density: 6.3, description: '高铝锌合金，含铜量高，强度高，耐磨性好。适用于重载场合。' },

  # ==================== 铜类 ====================
  { name: '紫铜 T2', code: 'CU-T2', kind: '铜', unit: 'kg', density: 8.96, description: '纯铜，导电性、导热性优良，塑性好。适用于电线电缆、散热器、管道等。' },
  { name: '黄铜 H62', code: 'CU-H62', kind: '铜', unit: 'kg', density: 8.5, description: '普通黄铜，含铜62%，力学性能好，切削加工性优良。适用于螺栓、螺母、连接件等。' },
  { name: '黄铜 H65', code: 'CU-H65', kind: '铜', unit: 'kg', density: 8.5, description: '易切削黄铜，含铅量高，切削加工性最好。适用于精密零件、钟表零件等。' },
  { name: '黄铜 H68', code: 'CU-H68', kind: '铜', unit: 'kg', density: 8.5, description: '塑性黄铜，含铜量高，延展性好。适用于深冲压件、弹壳等。' },
  { name: '黄铜 H70', code: 'CU-H70', kind: '铜', unit: 'kg', density: 8.5, description: '高强度黄铜，力学性能好，耐腐蚀。适用于船用零件、阀件等。' },
  { name: '青铜 QSn6.5-0.1', code: 'CU-QSN65', kind: '铜', unit: 'kg', density: 8.7, description: '锡青铜，耐磨性好，导电导热性优良。适用于轴承、齿轮、电器触点等。' },
  { name: '青铜 QAl9-4', code: 'CU-QAL94', kind: '铜', unit: 'kg', density: 7.6, description: '铝青铜，高强度、高硬度、耐腐蚀。适用于重载轴承、齿轮、螺旋桨等。' },
  { name: '铍青铜 QBe2', code: 'CU-QBE2', kind: '铜', unit: 'kg', density: 8.2, description: '铍青铜，高强度、高硬度、高弹性极限，无磁性。适用于弹簧、弹性件、仪表零件等。' },

  # ==================== 不锈钢类 ====================
  { name: '不锈钢 304', code: 'SS-304', kind: '不锈钢', unit: 'kg', density: 7.93, description: '奥氏体不锈钢，含铬18%、镍8%，耐腐蚀性优良，焊接性好。广泛用于食品、化工、建筑等。' },
  { name: '不锈钢 304L', code: 'SS-304L', kind: '不锈钢', unit: 'kg', density: 7.93, description: '低碳304不锈钢，含碳量低，焊接后无需退火。适用于需要焊接的场合。' },
  { name: '不锈钢 316', code: 'SS-316', kind: '不锈钢', unit: 'kg', density: 7.98, description: '钼元素不锈钢，耐氯化物腐蚀，抗点蚀。适用于海洋设备、制药、化工等。' },
  { name: '不锈钢 316L', code: 'SS-316L', kind: '不锈钢', unit: 'kg', density: 7.98, description: '低碳316不锈钢，焊接性好，耐腐蚀。适用于制药、食品加工、医疗器械等。' },
  { name: '不锈钢 430', code: 'SS-430', kind: '不锈钢', unit: 'kg', density: 7.7, description: '铁素体不锈钢，含铬17%，有磁性，硬度高。适用于家电、厨具、装饰等。' },
  { name: '不锈钢 420', code: 'SS-420', kind: '不锈钢', unit: 'kg', density: 7.7, description: '马氏体不锈钢，可淬火硬化，有磁性。适用于刀具、阀门、轴承等。' },
  { name: '不锈钢 201', code: 'SS-201', kind: '不锈钢', unit: 'kg', density: 7.93, description: '节镍不锈钢，价格低廉，耐腐蚀性较差。适用于装饰管、低成本制品等。' },
  { name: '双相不锈钢 2205', code: 'SS-2205', kind: '不锈钢', unit: 'kg', density: 7.82, description: '铁素体+奥氏体双相不锈钢，强度高，耐应力腐蚀。适用于化工、海洋、油气等。' },

  # ==================== 塑胶类 ====================
  { name: 'ABS 工程塑料', code: 'PL-ABS', kind: '塑胶', unit: 'kg', density: 1.05, description: '丙烯腈-丁二烯-苯乙烯共聚物，综合性能好，抗冲击、耐化学腐蚀，易加工。广泛用于家电、汽车、玩具等。' },
  { name: 'PC 聚碳酸酯', code: 'PL-PC', kind: '塑胶', unit: 'kg', density: 1.2, description: '聚碳酸酯，高抗冲击性，高韧性，透光率好。适用于光学件、电子元件、医疗器材等。' },
  { name: 'PP 聚丙烯', code: 'PL-PP', kind: '塑胶', unit: 'kg', density: 0.9, description: '聚丙烯，密度小，耐化学腐蚀，疲劳寿命长，可注塑、吹塑。适用于包装、汽车零件、日用品等。' },
  { name: 'PE 聚乙烯', code: 'PL-PE', kind: '塑胶', unit: 'kg', density: 0.94, description: '聚乙烯，优良的电绝缘性，耐化学腐蚀，无毒。适用于包装、电线绝缘、医疗器材等。' },
  { name: 'PVC 聚氯乙烯', code: 'PL-PVC', kind: '塑胶', unit: 'kg', density: 1.4, description: '聚氯乙烯，阻燃、耐磨、耐化学腐蚀，可软硬调整。适用于管材、电线、地板、人造革等。' },
  { name: 'PA6 尼龙6', code: 'PL-PA6', kind: '塑胶', unit: 'kg', density: 1.14, description: '聚酰胺6，耐磨、耐油、自润滑，抗冲击。适用于齿轮、轴承、油管等。' },
  { name: 'PA66 尼龙66', code: 'PL-PA66', kind: '塑胶', unit: 'kg', density: 1.14, description: '聚酰胺66，强度高，耐热性好，耐摩擦。适用于汽车零件、电子连接器等。' },
  { name: 'POM 聚甲醛', code: 'PL-POM', kind: '塑胶', unit: 'kg', density: 1.41, description: '聚甲醛，硬度高，耐磨性好，尺寸稳定。适用于齿轮、轴承、滑块等。' },
  { name: 'PMMA 亚克力', code: 'PL-PMMA', kind: '塑胶', unit: 'kg', density: 1.18, description: '聚甲基丙烯酸甲酯，高透明，高光泽，耐候性好。适用于光学件、广告牌、装饰品等。' },
  { name: 'PET 聚酯', code: 'PL-PET', kind: '塑胶', unit: 'kg', density: 1.34, description: '聚对苯二甲酸乙二醇酯，强度高，耐磨，尺寸稳定。适用于工程件、瓶子、纤维等。' },
  { name: 'TPU 热塑性聚氨酯', code: 'PL-TPU', kind: '塑胶', unit: 'kg', density: 1.21, description: '热塑性聚氨酯，高弹性，耐磨损，耐油污。适用于密封圈、电缆、鞋底等。' },
  { name: '硅胶 Silicone', code: 'PL-SIL', kind: '塑胶', unit: 'kg', density: 1.15, description: '硅橡胶，耐高温（-60℃~250℃），电绝缘性好，无毒。适用于密封件、餐具、医疗器材等。' },

  # ==================== 布料类 ====================
  { name: '纯棉面料', code: 'FB-COT', kind: '布料', unit: 'm', density: 0.25, description: '100%棉，吸湿透气性好，柔软舒适，耐水洗。适用于服装、家纺、医用等。' },
  { name: '涤纶面料', code: 'FB-PET', kind: '布料', unit: 'm', density: 0.2, description: '100%涤纶，强度高，弹性好，挺括耐穿，不缩水。适用于服装、工业用布、帐篷等。' },
  { name: '尼龙面料', code: 'FB-NYL', kind: '布料', unit: 'm', density: 0.15, description: '100%尼龙，耐磨，强度高，轻便。适用于运动服、背包、降落伞等。' },
  { name: '帆布', code: 'FB-CAN', kind: '布料', unit: 'm', density: 0.3, description: '纯棉或涤棉帆布，厚实耐磨，结构紧密。适用于箱包、鞋材、工业用布等。' },
  { name: '真丝面料', code: 'FB-SIL', kind: '布料', unit: 'm', density: 0.08, description: '100%桑蚕丝，光泽华丽，手感柔软，吸湿透气。适用于高档服装、围巾等。' },
  { name: '羊毛面料', code: 'FB-WOL', kind: '布料', unit: 'm', density: 0.25, description: '100%羊毛，保暖性好，弹性好，吸湿性强。适用于冬季服装、地毯等。' },
  { name: '麻布', code: 'FB-LIN', kind: '布料', unit: 'm', density: 0.18, description: '100%亚麻，透气性好，吸湿排汗，天然抑菌。适用于夏季服装、家纺等。' },
  { name: '混纺面料（涤棉）', code: 'FB-BLD', kind: '布料', unit: 'm', density: 0.2, description: '65%涤纶+35%棉，兼顾棉的舒适性和涤纶的挺括性。适用于服装、床单等。' },
  { name: '弹力面料（莱卡）', code: 'FB-ELA', kind: '布料', unit: 'm', density: 0.2, description: '95%棉/涤纶+5%莱卡，具有良好的弹性和回复性。适用于紧身服装、运动服等。' },
  { name: '防雨布', code: 'FB-WP', kind: '布料', unit: 'm', density: 0.35, description: 'PVC或PU涂层尼龙/涤纶，防水性能好。适用于雨衣、帐篷、户外用品等。' },

  # ==================== 皮料类 ====================
  { name: '头层牛皮', code: 'LT-COW', kind: '皮料', unit: 'm²', density: 1.0, description: '天然头层牛皮，粒面细致，强度高，耐用，手感好。适用于高档皮具、皮鞋、家具等。' },
  { name: '二层牛皮', code: 'LT-COW2', kind: '皮料', unit: 'm²', density: 0.8, description: '牛皮二层，经修面和整理后使用，价格适中。适用于皮具、箱包等。' },
  { name: '羊皮（山羊皮）', code: 'LT-GOT', kind: '皮料', unit: 'm²', density: 0.55, description: '山羊皮，轻薄柔软，粒面细腻。适用于高档服装、手套、皮具等。' },
  { name: '羊皮（绵羊皮）', code: 'LT-SHE', kind: '皮料', unit: 'm²', density: 0.7, description: '绵羊皮，柔软度极高，保暖性好。适用于皮衣、手套、地毯等。' },
  { name: '猪皮', code: 'LT-PIG', kind: '皮料', unit: 'm²', density: 1.2, description: '猪皮，强度较高，毛孔粗大，透气性好。适用于鞋衬、皮具、沙发等。' },
  { name: '鹿皮', code: 'LT-DEE', kind: '皮料', unit: 'm²', density: 0.5, description: '鹿皮，柔软轻韧，毛孔细腻。适用于擦拭布、手套、装饰等。' },
  { name: 'PU 合成革', code: 'LT-PU', kind: '皮料', unit: 'm²', density: 0.6, description: '聚氨酯合成革，外观接近真皮，耐磨，防水，价格适中。适用于家具、服装、箱包等。' },
  { name: 'PVC 人造革', code: 'LT-PVC', kind: '皮料', unit: 'm²', density: 0.4, description: '聚氯乙烯人造革，防水，耐化学腐蚀，价格低廉。适用于家具、汽车内饰、雨衣等。' },
  { name: '超纤皮（微纤维）', code: 'LT-SF', kind: '皮料', unit: 'm²', density: 0.7, description: '超细纤维合成革，手感接近真皮，耐磨，耐折。适用于高档箱包、鞋材、沙发等。' },
  { name: '再生革', code: 'LT-RG', kind: '皮料', unit: 'm²', density: 0.4, description: '再生革，由皮革碎料制成，价格低廉，强度较低。适用于低成本应用，如笔记本封面等。' },
]

# 参考价格
price_map = {
  '锌合金' => 180.0,
  '铜' => 65.0,
  '不锈钢' => 25.0,
  '塑胶' => 25.0,
  '布料' => 30.0,
  '皮料' => 200.0
}

# 添加材料和价格
materials_data.each do |data|
  material = Material.find_or_create_by!(code: data[:code]) do |m|
    m.name = data[:name]
    m.kind = data[:kind]
    m.unit = data[:unit]
    m.density = data[:density]
    m.description = data[:description]
  end

  # 添加一个初始价格
  base_price = price_map[data[:kind]] || 50.0
  MaterialPrice.find_or_create_by!(material: material, effective_date: Date.today) do |mp|
    mp.price_per_unit = base_price
    mp.source = '参考市场价'
    mp.currency = 'CNY'
  end
end

puts "材质数据添加完成！"
puts ""

# 统计各类别材料数量
Material.group(:kind).count.each do |type, count|
  puts "#{type}: #{count} 种"
end

puts ""
puts "共添加 #{Material.count} 种常见材质！"
