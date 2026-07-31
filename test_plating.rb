#!/usr/bin/env ruby
# 测试产品新建页面
require 'net/http'

http = Net::HTTP.new('localhost', 3000)
request = Net::HTTP::Get.new('/products/new')
request['User-Agent'] = 'Mozilla/5.0'
response = http.request(request)

puts "Status: #{response.code}"
body = response.body.force_encoding('UTF-8')

if body.include?('电镀颜色')
  puts "SUCCESS: 页面包含'电镀颜色'字段"
else
  puts "FAILED: 页面未找到'电镀颜色'字段"
  # 查找错误信息
  if body.include?('error') || body.include?('Error')
    # 输出部分错误信息
    puts body.scan(/error[^<]*/i).first(5)
  end
end

# 检查是否包含PLATING_COLORS相关内容
if body.include?('金色') && body.include?('玫瑰金')
  puts "SUCCESS: 电镀颜色选项正确显示"
else
  puts "INFO: 检查电镀颜色选项..."
end
