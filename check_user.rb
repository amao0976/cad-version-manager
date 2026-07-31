#!/usr/bin/env ruby
# Simple test to check user and password validity
require_relative 'config/environment'

user = User.find_by(email: 'manager@example.com')

if user
  puts "User found: #{user.email}"
  puts "Role: #{user.role}"
  puts "Encrypted password: #{user.encrypted_password[0..50]}..."

  # Test password
  if user.valid_password?('123456')
    puts "SUCCESS: Password '123456' is correct!"
  else
    puts "FAILED: Password '123456' is NOT correct"
    puts "Testing 'password'..."
    if user.valid_password?('password')
      puts "SUCCESS: Password 'password' is correct!"
    end
    puts "Testing 'password123'..."
    if user.valid_password?('password123')
      puts "SUCCESS: Password 'password123' is correct!"
    end
  end

  # Check if user is active
  puts "User persisted?: #{user.persisted?}"
  puts "User new_record?: #{user.new_record?}"
else
  puts "User NOT found with email: manager@example.com"
  puts "All users:"
  User.all.each { |u| puts "  - #{u.email} (#{u.role})" }
end
