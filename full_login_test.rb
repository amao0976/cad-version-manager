#!/usr/bin/env ruby
require 'net/http'
require 'uri'

# Step 1: Get login page with session
jar = []

# First request - get cookie and CSRF
uri = URI('http://localhost:3000/users/sign_in')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)
request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
response = http.request(request)

# Save cookies
response.get_fields('Set-Cookie').each do |sc|
  cookie = sc.split(';')[0]
  jar << cookie
end

# Extract CSRF token
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1]
puts "CSRF Token found"

# Step 2: Submit login form with cookies
login_data = URI.encode_www_form({
  'authenticity_token' => csrf_token,
  'user' => {
    'email' => 'manager@example.com',
    'password' => '123456',
    'remember_me' => '0'
  }
})

login_request = Net::HTTP::Post.new('/users/sign_in')
login_request['Content-Type'] = 'application/x-www-form-urlencoded'
login_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
login_request['Cookie'] = jar.join('; ')
login_request['Referer'] = 'http://localhost:3000/users/sign_in'
login_request.body = "authenticity_token=#{URI.encode_www_form_component(csrf_token)}&user%5Bemail%5D=manager%40example.com&user%5Bpassword%5D=123456&user%5Bremember_me%5D=0"

login_response = http.request(login_request)

puts "Login attempt status: #{login_response.code}"
puts "Location: #{login_response['Location']}"

# Update cookies from login response
login_response.get_fields('Set-Cookie').each do |sc|
  cookie = sc.split(';')[0]
  jar << cookie
end

# Step 3: Follow redirect if successful
if login_response.code.to_i >= 300 && login_response.code.to_i < 400
  redirect_url = login_response['Location']
  puts "Following redirect to: #{redirect_url}"

  redirect_uri = URI(redirect_url)
  redirect_request = Net::HTTP::Get.new(redirect_uri.request_uri)
  redirect_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
  redirect_request['Cookie'] = jar.join('; ')
  redirect_request['Referer'] = 'http://localhost:3000/users/sign_in'

  final_response = http.request(redirect_request)
  puts "Final status: #{final_response.code}"
  puts "Final URL path: #{redirect_uri.request_uri}"

  # Check if we're logged in
  if final_response.body.include?('仪表板') || final_response.body.include?('Dashboard') || final_response.body.include?('欢迎回来')
    puts "\nSUCCESS: LOGIN SUCCESSFUL!"
  elsif final_response.body.include?('Invalid email or password')
    puts "\nFAILED: Invalid email or password"
  elsif final_response.body.include?('sign_in')
    puts "\nFAILED: Still showing login page"
    puts "Error message:"
    error_match = final_response.body.match(/class="[^"]*alert[^"]*"[^>]*>([^<]+)/)
    if error_match
      puts "  #{error_match[1].strip}"
    end
  else
    puts "\nUNKNOWN STATE"
    puts "Body preview: #{final_response.body[0..300]}"
  end
else
  puts "No redirect - showing login page with errors"
  puts "Body preview: #{login_response.body[0..300]}"
end