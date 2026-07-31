#!/usr/bin/env ruby
# Encoding: UTF-8
require 'net/http'
require 'uri'

jar = []

# Step 1: Get login page
uri = URI('http://localhost:3000/users/sign_in')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)
request['User-Agent'] = 'Mozilla/5.0'
response = http.request(request)

response.get_fields('Set-Cookie').each { |sc| jar << sc.split(';')[0] }
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1]

# Step 2: Login
login_request = Net::HTTP::Post.new('/users/sign_in')
login_request['Content-Type'] = 'application/x-www-form-urlencoded'
login_request['User-Agent'] = 'Mozilla/5.0'
login_request['Cookie'] = jar.join('; ')
login_request['Referer'] = 'http://localhost:3000/users/sign_in'
login_request.body = "authenticity_token=#{URI.encode_www_form_component(csrf_token)}&user%5Bemail%5D=manager%40example.com&user%5Bpassword%5D=123456&user%5Bremember_me%5D=0"

login_response = http.request(login_request)

puts "Login status: #{login_response.code}"
puts "Location: #{login_response['Location']}"

login_response.get_fields('Set-Cookie').each { |sc| jar << sc.split(';')[0] }

# Step 3: Check if logged in by visiting root
check_request = Net::HTTP::Get.new('/')
check_request['User-Agent'] = 'Mozilla/5.0'
check_request['Cookie'] = jar.join('; ')
check_response = http.request(check_request)

puts "Root page status: #{check_response.code}"

# Force UTF-8 encoding
body = check_response.body.force_encoding('UTF-8')

if body.include?('仪表板') || body.include?('Dashboard') || body.include?('欢迎回来')
  puts "\nSUCCESS: LOGIN IS WORKING!"
  puts "You are now logged in as manager@example.com"
elsif body.include?('sign_in') || body.include?('登录')
  puts "\nFAILED: Still on login page"
else
  puts "\nChecking content..."
  puts "Body contains 'sign_in': #{body.include?('sign_in')}"
  puts "Body contains 'Dashboard': #{body.include?('Dashboard')}"
  puts "Body contains '仪表板': #{body.include?('仪表板')}"
end