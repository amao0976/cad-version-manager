#!/usr/bin/env ruby
require_relative 'config/environment'

puts "所有分类:"
puts "=" * 60
Category.all.each do |c|
  parent_name = c.parent ? c.parent.name : "根分类"
  puts "ID: #{c.id} | 名称: #{c.name} | 编码: #{c.code} | 父级: #{parent_name} | 产品数: #{c.products.count}"
end

puts ""
puts "检查重复分类:"
puts "=" * 60
duplicates = Category.group(:name).having('count(*) > 1').count
if duplicates.any?
  duplicates.each do |name, count|
    puts "重复名称: '#{name}' 出现 #{count} 次"
    Category.where(name: name).each do |c|
      puts "  ID: #{c.id} | 父级ID: #{c.parent_id} | 产品数: #{c.products.count}"
    end
  end
else
  puts "没有发现重复分类"
end
