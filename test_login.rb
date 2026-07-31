#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'cookiejar'
require 'cookiejar/parser'

# Create cookie jar
jar = CookieJar::Jar.new

# Step 1: Get login page
uri = URI('http://localhost:3000/users/sign_in')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)

# Extract cookies
response.get_fields('Set-Cookie').each do |cookie|
  jar.set_cookie(CookieJar::ParseCookie.parse(cookie))
end

# Extract CSRF token
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1]
puts "CSRF Token: #{csrf_token[0..20]}..."

# Step 2: Submit login form with cookie
login_uri = URI('http://localhost:3000/users/sign_in')
login_http = Net::HTTP.new(login_uri.host, login_uri.port)
login_request = Net::HTTP::Post.new(login_uri.request_uri)

# Set cookies
cookie_string = jar.cookies_for_url(login_uri).map { |c| "#{c.name}=#{c.value}" }.join('; ')
login_request['Cookie'] = cookie_string
login_request['Content-Type'] = 'application/x-www-form-urlencoded'
login_request['User-Agent'] = 'Mozilla/5.0'

# Set form data with authenticity token
form_data = "authenticity_token=#{URI.encode_www_form_component(csrf_token)}&user%5Bemail%5D=manager%40example.com&user%5Bpassword%5D=123456&user%5Bremember_me%5D=0"
login_request.body = form_data

# Follow redirects
login_response = login_http.request(login_request)

puts "Status: #{login_response.code}"
puts "Location: #{login_response['Location']}"

# If redirect, follow it
if login_response.code.to_i >= 300 && login_response.code.to_i < 400
  redirect_uri = URI(login_response['Location'])
  redirect_http = Net::HTTP.new(redirect_uri.host, redirect_uri.port)
  redirect_request = Net::HTTP::Get.new(redirect_uri.request_uri)

  # Update cookies from response
  login_response.get_fields('Set-Cookie').each do |cookie|
    begin
      jar.set_cookie(CookieJar::ParseCookie.parse(cookie))
    rescue
    end
  end

  cookie_string = jar.cookies_for_url(redirect_uri).map { |c| "#{c.name}=#{c.value}" }.join('; ')
  redirect_request['Cookie'] = cookie_string
  redirect_request['User-Agent'] = 'Mozilla/5.0'

  final_response = redirect_http.request(redirect_request)
  puts "Final Status: #{final_response.code}"
  puts "Final URL: #{redirect_uri}"

  if final_response.body.include?('仪表板') || final_response.body.include?('Dashboard') || final_response.body.include?('dashboard')
    puts "SUCCESS: Logged in successfully!"
  elsif final_response.body.include?('Invalid email or password')
    puts "FAILED: Invalid credentials"
  elsif final_response.body.include?('sign_in')
    puts "FAILED: Still on login page"
  else
    puts "Content preview: #{final_response.body[0..500]}"
  end
else
  puts "Response body preview: #{login_response.body[0..500]}"
end
