require 'net/http'
require 'uri'

def http(method, path, cookie = nil, body = nil, headers = {})
  http = Net::HTTP.new('localhost', 3000)
  http.use_ssl = false
  req = case method
        when :get then Net::HTTP::Get.new(path)
        when :post then Net::HTTP::Post.new(path)
        end
  req['Cookie'] = cookie if cookie
  req['Content-Type'] = 'application/x-www-form-urlencoded' if body
  headers.each { |k, v| req[k] = v }
  req.body = body if body
  http.request(req)
end

# Get login page
resp = http(:get, '/users/sign_in')
cookie = resp['Set-Cookie']&.split(';')&.first
meta_token = resp.body.match(/<meta name="csrf-token" content="([^"]+)"/)&.values_at(1)&.first
form_token = resp.body.match(/name="authenticity_token" value="([^"]+)"/)&.values_at(1)&.first

puts "Meta CSRF Token: #{meta_token[0..40]}..." if meta_token
puts "Form Token: #{form_token[0..40]}..." if form_token

# Try login with form token
login_data = URI.encode_www_form({
  'user[email]' => 'manager@example.com',
  'user[password]' => 'password123',
  'authenticity_token' => form_token
})
resp = http(:post, '/users/sign_in', cookie, login_data)
cookie = resp['Set-Cookie']&.split(';')&.first || cookie
puts "\nLogin result: #{resp.code} -> #{resp['Location']}"
puts "Body preview: #{resp.body.force_encoding('UTF-8')[0..500]}"

# Try with meta token
login_data2 = URI.encode_www_form({
  'user[email]' => 'manager@example.com',
  'user[password]' => 'password123',
  'authenticity_token' => meta_token
})
resp2 = http(:post, '/users/sign_in', cookie, login_data2)
cookie2 = resp2['Set-Cookie']&.split(';')&.first || cookie
puts "\nLogin (meta token): #{resp2.code} -> #{resp2['Location']}"
puts "Body preview: #{resp2.body.force_encoding('UTF-8')[0..500]}"

# Try with X-CSRF-Token header
resp3 = http(:post, '/users/sign_in', cookie, login_data2, { 'X-CSRF-Token' => meta_token })
cookie3 = resp3['Set-Cookie']&.split(';')&.first || cookie
puts "\nLogin (header): #{resp3.code} -> #{resp3['Location']}"
puts "Body preview: #{resp3.body.force_encoding('UTF-8')[0..500]}"
