#!/usr/bin/env ruby
# Encoding: UTF-8
require 'net/http'
require 'uri'

http = Net::HTTP.new('localhost', 3000)
http.open_timeout = 10
http.read_timeout = 30

# Step 1: Get login page
request = Net::HTTP::Get.new('/users/sign_in')
request['User-Agent'] = 'Mozilla/5.0'
response = http.request(request)

cookie = response.get_fields('Set-Cookie').map { |s| s.split(';')[0] }.join('; ')
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1]

puts "Got login page, CSRF token extracted"

# Step 2: Login with new password
login_body = URI.encode_www_form({
  'authenticity_token' => csrf_token,
  'user[email]' => 'manager@example.com',
  'user[password]' => 'password123',
  'user[remember_me]' => '0'
})

request2 = Net::HTTP::Post.new('/users/sign_in')
request2['Content-Type'] = 'application/x-www-form-urlencoded'
request2['User-Agent'] = 'Mozilla/5.0'
request2['Cookie'] = cookie
request2.body = login_body

response2 = http.request(request2)

puts "\nLogin POST response:"
puts "Status: #{response2.code}"
puts "Location: #{response2['Location']}"

# Get new cookies from login response
new_cookies = response2.get_fields('Set-Cookie')
puts "Set-Cookie count: #{new_cookies&.size || 0}"

all_cookies = ([cookie] + new_cookies.to_a.map { |s| s.split(';')[0] }).compact.reject(&:empty?).join('; ')

puts "Cookie count: #{all_cookies.split(';').size}"

# Step 3: Check protected page with cookies
request3 = Net::HTTP::Get.new('/')
request3['User-Agent'] = 'Mozilla/5.0'
request3['Cookie'] = all_cookies

response3 = http.request(request3)

puts "\nProtected page check:"
puts "Status: #{response3.code}"
puts "Location: #{response3['Location']}"

body = response3.body.force_encoding('UTF-8')

# Check if we're logged in by checking for content
if body.include?('sign_in')
  puts "\nFAILED: Still redirected to login page"
  puts "This means session cookie was not properly set or verified"
else
  has_dashboard = body.include?('仪表板') || body.include?('dashboard')
  has_nav = body.include?('仪表盘') || body.include?('项目') || body.include?('BOM')
  
  puts "Contains dashboard content: #{has_dashboard}"
  puts "Contains navigation: #{has_nav}"
  puts "\nBody preview (first 300 chars):"
  puts body[0..300]
end
