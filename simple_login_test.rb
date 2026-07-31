#!/usr/bin/env ruby
# Encoding: UTF-8
require 'net/http'
require 'uri'

# Create HTTP client
http = Net::HTTP.new('localhost', 3000)
http.open_timeout = 10
http.read_timeout = 30

# Step 1: Get login page
request = Net::HTTP::Get.new('/users/sign_in')
request['User-Agent'] = 'Mozilla/5.0'
response = http.request(request)

# Get cookie from response
cookie = response.get_fields('Set-Cookie').map { |s| s.split(';')[0] }.join('; ')
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1]

puts "Step 1: Got login page"
puts "Cookie: #{cookie[0..50]}..."

# Step 2: POST login
login_body = URI.encode_www_form({
  'authenticity_token' => csrf_token,
  'user[email]' => 'manager@example.com',
  'user[password]' => '123456',
  'user[remember_me]' => '0'
})

request2 = Net::HTTP::Post.new('/users/sign_in')
request2['Content-Type'] = 'application/x-www-form-urlencoded'
request2['User-Agent'] = 'Mozilla/5.0'
request2['Cookie'] = cookie
request2.body = login_body

response2 = http.request(request2)

puts "\nStep 2: Login POST response"
puts "Status: #{response2.code}"
puts "Location: #{response2['Location']}"

# Get new cookies
new_cookies = response2.get_fields('Set-Cookie')
all_cookies = ([cookie] + new_cookies.map { |s| s.split(';')[0] }).compact.reject(&:empty?).join('; ')

# Step 3: Check protected page
request3 = Net::HTTP::Get.new('/')
request3['User-Agent'] = 'Mozilla/5.0'
request3['Cookie'] = all_cookies

response3 = http.request(request3)

puts "\nStep 3: Protected page response"
puts "Status: #{response3.code}"
body = response3.body.force_encoding('UTF-8')

if body.include?('dashboard') || body.include?('仪表板') || body.include?('Welcome')
  puts "\nSUCCESS! Login is working!"
else
  puts "\nFAILED or redirected"
  puts "Redirect to: #{response3['Location']}"
  puts "Body preview: #{body.scan(/title[^>]*>[^<]+/).first}"
end