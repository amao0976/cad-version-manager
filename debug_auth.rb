# 模拟 Devise 登录流程
user = User.find_by(email: 'manager@example.com')
puts "User found: #{user.email}"
puts "Encrypted password: #{user.encrypted_password[0..30]}..."

# 验证密码
result = user.valid_password?('password123')
puts "valid_password?('password123'): #{result}"

# 模拟 Devise 的认证过程
# Devise 使用 Warden 进行认证
puts "\n模拟认证过程..."

# 检查 User 模型的 authentication_keys
puts "authentication_keys: #{Devise.authentication_keys}"

# 检查是否有 :validatable 模块
puts "User modules: #{user.class.devise_modules}"

# 手动测试 find_for_authentication
found_user = User.find_for_authentication(email: 'manager@example.com')
puts "find_for_authentication: #{found_user&.email}"

# 检查参数是否会被处理
# Devise 会从 params 中获取 user[email] 和 user[password]
# 然后调用 valid_password?
