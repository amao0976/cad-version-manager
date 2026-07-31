#!/usr/bin/env ruby
require_relative 'config/environment'

puts "清理重复分类..."
puts "=" * 60

# 1. 处理重复的"手表"分类
# 保留 ID:1 (有产品关联)，删除 ID:2 (无产品关联)
watch_dup = Category.find_by(name: '手表', id: 2)
if watch_dup
  puts "删除重复分类: ID=#{watch_dup.id}, 名称=#{watch_dup.name}, 编码=#{watch_dup.code}"
  # 先检查是否有子分类
  children = watch_dup.children
  if children.any?
    puts "  子分类数量: #{children.count}"
    # 将子分类转移到保留的分类下
    keep_watch = Category.find(1)
    children.each do |child|
      child.update(parent: keep_watch)
      puts "  转移子分类: #{child.name} (ID: #{child.id}) 到父分类 ID:1"
    end
  end
  watch_dup.destroy
  puts "  已删除重复的'手表'分类 ID:2"
else
  puts "未找到重复的'手表'分类"
end

# 2. 处理重复的"雨伞"分类
# ID:19 是 ID:5 的子分类，名称相同
umbrella_parent = Category.find_by(name: '雨伞', parent_id: nil)
umbrella_child = Category.find_by(name: '雨伞', parent: umbrella_parent)

if umbrella_child
  puts "\n处理'雨伞'子分类:"
  puts "  父分类 ID:5 名称:雨伞"
  puts "  子分类 ID:19 名称:雨伞 (与父同名)"
  
  # 检查子分类是否有产品关联
  if umbrella_child.products.any?
    puts "  子分类有产品关联，需要重新命名"
    # 将子分类重命名为"普通雨伞"或删除
  else
    puts "  子分类无产品关联，可以删除"
    umbrella_child.destroy
    puts "  已删除重复的子分类'雨伞' ID:19"
  end
end

puts "\n清理后所有分类:"
puts "=" * 60
Category.all.each do |c|
  parent_name = c.parent ? c.parent.name : "根分类"
  puts "ID: #{c.id} | 名称: #{c.name} | 编码: #{c.code} | 父级: #{parent_name} | 产品数: #{c.products.count}"
end

puts "\n完成！"
