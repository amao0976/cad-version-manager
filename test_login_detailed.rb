require 'net/http'
require 'uri'

http = Net::HTTP.new('localhost', 3000)
http.use_ssl = false

# Step 1: Get login page
resp1 = http.get('/users/sign_in')
cookie1 = resp1['Set-Cookie']&.split(';')&.first
token = resp1.body.match(/name="authenticity_token" value="([^"]+)"/)&.values_at(1)&.first

puts "Step 1 - Get login page:"
puts "  Status: #{resp1.code}"
puts "  Cookie: #{cookie1.to_s[0..60]}..."
puts "  Token: #{token.to_s[0..40]}..."

# Step 2: Submit login form (same as browser would)
form_params = {
  'authenticity_token' => token,
  'user[email]' => 'manager@example.com',
  'user[password]' => 'password123',
  'user[remember_me]' => '1',
  'commit' => '登录'
}

body = URI.encode_www_form(form_params)
req = Net::HTTP::Post.new('/users/sign_in')
req['Cookie'] = cookie1
req['Content-Type'] = 'application/x-www-form-urlencoded'
req['Accept'] = 'text/html'
req.body = body

resp2 = http.request(req)
cookie2 = resp2['Set-Cookie']&.split(';')&.first

puts "\nStep 2 - Submit login:"
puts "  Status: #{resp2.code}"
puts "  Location: #{resp2['Location']}"
puts "  Cookie: #{cookie2.to_s[0..60]}..."

# Check if login succeeded
if resp2.code.to_s.start_with?('3')
  puts "\n  LOGIN SUCCESSFUL!"
  # Follow redirect
  location = resp2['Location']
  puts "  Following redirect to: #{location}"
  
  # Use new cookie
  current_cookie = cookie2 || cookie1
  resp3 = http.get('/', { 'Cookie' => current_cookie })
  puts "  Home page: #{resp3.code}"
  
  if resp3['Location']
    puts "  Redirect to: #{resp3['Location']}"
  end
else
  puts "\n  LOGIN FAILED!"
  # Check for error messages
  body_text = resp2.body.force_encoding('UTF-8')
  if body_text.include?('Invalid email or password')
    puts "  Error: Invalid email or password"
  end
  
  # Check params in the response
  puts "\n  Debug - Params sent:"
  form_params.each { |k, v| puts "    #{k}: #{v[0..30]}" }
end
