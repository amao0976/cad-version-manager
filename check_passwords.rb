#!/usr/bin/env ruby
# Encoding: UTF-8
require_relative 'config/environment'

user = User.find_by(email: 'manager@example.com')

if user
  puts "User found: #{user.email}"
  puts "Role: #{user.role}"
  puts "Created at: #{user.created_at}"
  puts "Encrypted password: #{user.encrypted_password[0..50]}..."
  
  # Test multiple passwords
  passwords = ['password123', '123456', 'password', 'password12']
  passwords.each do |pwd|
    result = user.valid_password?(pwd)
    puts "  Password '#{pwd}': #{result ? 'VALID' : 'invalid'}"
  end
else
  puts "User NOT found with email: manager@example.com"
  puts "\nAll users:"
  User.all.each { |u| puts "  - #{u.email} (#{u.role})" }
end
