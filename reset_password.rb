# 重置密码
user = User.find_by(email: 'manager@example.com')
user.password = '123456'
user.password_confirmation = '123456'
if user.save
  puts "Password reset successful!"
  puts "Email: #{user.email}"
  puts "New password: 123456"
  
  # Verify
  puts "Valid?: #{user.valid_password?('123456')}"
else
  puts "Errors: #{user.errors.full_messages}"
end
