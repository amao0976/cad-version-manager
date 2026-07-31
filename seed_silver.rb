#!/usr/bin/env ruby
# Encoding: UTF-8
# 添加925银等贵金属材质

require_relative 'config/environment'

silver_materials = [
  { name: '925纯银', code: 'AG-925', kind: '银', unit: 'g', density: 10.36, description: '含银量92.5%的标准纯银，添加7.5%的铜增加硬度。广泛用于首饰、餐具、电子元件等。' },
  { name: '999足银', code: 'AG-999', kind: '银', unit: 'g', density: 10.5, description: '含银量99.9%的高纯银，质地柔软，导电性好。适用于投资收藏、电器接触点等。' },
  { name: '990足银', code: 'AG-990', kind: '银', unit: 'g', density: 10.4, description: '含银量99%的纯银，较999银硬度略高。适用于首饰、工艺品等。' },
  { name: '800银', code: 'AG-800', kind: '银', unit: 'g', density: 9.8, description: '含银量80%的银合金，硬度较高，耐磨。适用于餐具、器具等。' },
  { name: '银合金', code: 'AG-ALLOY', kind: '银', unit: 'g', density: 10.0, description: '银与铜、锌等金属的合金，强度高，硬度好。适用于首饰、电气接触点等。' },
  { name: '镀金合金（镀银）', code: 'AG-PLATE', kind: '银', unit: 'g', density: 8.9, description: '铜或镍基底镀银，外观与纯银相似，价格低廉。适用于首饰、餐具等。' },
]

price_map = {
  '银' => 8.0
}

silver_materials.each do |data|
  material = Material.find_or_create_by!(code: data[:code]) do |m|
    m.name = data[:name]
    m.kind = data[:kind]
    m.unit = data[:unit]
    m.density = data[:density]
    m.description = data[:description]
  end

  base_price = price_map[data[:kind]] || 50.0
  MaterialPrice.find_or_create_by!(material: material, effective_date: Date.today) do |mp|
    mp.price_per_unit = base_price
    mp.source = '参考市场价'
    mp.currency = 'CNY'
  end
end

puts "银材质添加完成！"
puts ""
Material.where(kind: '银').each do |m|
  puts "  #{m.code} - #{m.name}"
end
puts ""
puts "共添加 #{Material.where(kind: '银').count} 种银材质！"
