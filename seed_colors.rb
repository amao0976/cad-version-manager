#!/usr/bin/env ruby
# Encoding: UTF-8
# 添加颜色管理种子数据

require_relative 'config/environment'

# 电镀颜色
plating_colors = [
  { name: '金色', code: 'GOLD', color_type: 'plating', hex_code: '#FFD700', description: '电镀金色，最常用的电镀颜色之一，高贵典雅。' },
  { name: '玫瑰金', code: 'ROSE_GOLD', color_type: 'plating', hex_code: '#B76E79', description: '电镀玫瑰金，粉色调，温柔浪漫，广泛用于首饰。' },
  { name: '银色', code: 'SILVER', color_type: 'plating', hex_code: '#C0C0C0', description: '电镀银色，经典优雅，百搭款式。' },
  { name: '铑色', code: 'RHODIUM', color_type: 'plating', hex_code: '#E5E4E2', description: '电镀铑色，明亮的银白色，常用于高端首饰。' },
  { name: '黑铑', code: 'BLACK_RHODIUM', color_type: 'plating', hex_code: '#3D3D3D', description: '电镀黑铑色，时尚个性，适合酷炫风格。' },
  { name: '枪色', code: 'GUNMETAL', color_type: 'plating', hex_code: '#3E3E42', description: '电镀枪色，深灰黑色，沉稳大气。' },
  { name: '古铜色', code: 'BRONZE', color_type: 'plating', hex_code: '#CD7F32', description: '电镀古铜色，复古质感，常用于仿古风格。' },
  { name: '镍色', code: 'NICKEL', color_type: 'plating', hex_code: '#A8A9AD', description: '电镀镍色，银白色，耐腐蚀性好。' },
  { name: '铬色', code: 'CHROME', color_type: 'plating', hex_code: '#F0F0F0', description: '电镀铬色，明亮如镜，常用于手表外壳。' },
  { name: '彩色电镀', code: 'RAINBOW', color_type: 'plating', hex_code: '#FF00FF', description: '彩色电镀，彩虹色，时尚个性。' }
]

# 布料皮料颜色
fabric_leather_colors = [
  { name: '黑色', code: 'BLACK', color_type: 'fabric_leather', hex_code: '#000000', description: '经典黑色，百搭款式。' },
  { name: '白色', code: 'WHITE', color_type: 'fabric_leather', hex_code: '#FFFFFF', description: '纯净白色，优雅大方。' },
  { name: '灰色', code: 'GREY', color_type: 'fabric_leather', hex_code: '#808080', description: '中灰色，中性色调。' },
  { name: '深蓝色', code: 'NAVY', color_type: 'fabric_leather', hex_code: '#000080', description: '深蓝色，沉稳大气。' },
  { name: '浅蓝色', code: 'LIGHT_BLUE', color_type: 'fabric_leather', hex_code: '#ADD8E6', description: '浅蓝色，清新淡雅。' },
  { name: '红色', code: 'RED', color_type: 'fabric_leather', hex_code: '#FF0000', description: '经典红色，热情奔放。' },
  { name: '酒红色', code: 'WINE', color_type: 'fabric_leather', hex_code: '#722F37', description: '酒红色，高贵典雅。' },
  { name: '粉色', code: 'PINK', color_type: 'fabric_leather', hex_code: '#FFC0CB', description: '粉色，温柔甜美。' },
  { name: '米色', code: 'BEIGE', color_type: 'fabric_leather', hex_code: '#F5F5DC', description: '米色，温和中性。' },
  { name: '棕色', code: 'BROWN', color_type: 'fabric_leather', hex_code: '#8B4513', description: '棕色，大地色系。' },
  { name: '咖啡色', code: 'COFFEE', color_type: 'fabric_leather', hex_code: '#6F4E37', description: '咖啡色，温暖沉稳。' },
  { name: '卡其色', code: 'KHAKI', color_type: 'fabric_leather', hex_code: '#BDB76B', description: '卡其色，休闲风格。' },
  { name: '绿色', code: 'GREEN', color_type: 'fabric_leather', hex_code: '#008000', description: '绿色，清新自然。' },
  { name: '翠绿色', code: 'EMERALD', color_type: 'fabric_leather', hex_code: '#50C878', description: '翠绿色，鲜亮醒目。' },
  { name: '紫色', code: 'PURPLE', color_type: 'fabric_leather', hex_code: '#800080', description: '紫色，神秘高贵。' }
]

# 其他颜色
other_colors = [
  { name: '橙色', code: 'ORANGE', color_type: 'other', hex_code: '#FFA500', description: '橙色，活力四射。' },
  { name: '黄色', code: 'YELLOW', color_type: 'other', hex_code: '#FFFF00', description: '黄色，明亮欢快。' },
  { name: '荧光绿', code: 'NEON_GREEN', color_type: 'other', hex_code: '#39FF14', description: '荧光绿，醒目动感。' },
  { name: '透明色', code: 'TRANSPARENT', color_type: 'other', hex_code: '#00000000', description: '透明/无色，适用于透明材质。' }
]

# 添加所有颜色
[plating_colors, fabric_leather_colors, other_colors].flatten.each do |data|
  Color.find_or_create_by!(code: data[:code]) do |c|
    c.name = data[:name]
    c.color_type = data[:color_type]
    c.hex_code = data[:hex_code]
    c.description = data[:description]
    c.active = true
  end
end

puts "颜色种子数据添加完成！"
puts ""

# 统计各类别颜色数量
Color.group(:color_type).count.each do |type, count|
  label = Color.color_types.key(type) || type
  puts "#{label}: #{count} 种"
end

puts ""
puts "共添加 #{Color.count} 种颜色！"
