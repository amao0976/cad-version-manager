#!/usr/bin/env ruby
# Test login functionality using Rails test helpers

require_relative 'config/environment'
require 'rack/test'

class LoginTest
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def run
    # Step 1: Get login page
    get '/users/sign_in'
    puts "1. Login page status: #{last_response.status}"

    if last_response.status == 200
      # Extract CSRF token
      csrf_match = last_response.body.match(/name="authenticity_token" value="([^"]+)"/)
      if csrf_match
        @csrf_token = csrf_match[1]
        puts "2. CSRF token extracted successfully"
      else
        puts "2. FAILED: Cannot extract CSRF token"
        puts "Body preview: #{last_response.body[0..300]}"
        return
      end
    end

    # Step 2: Submit login form
    post '/users/sign_in', {
      'authenticity_token' => @csrf_token,
      'user' => {
        'email' => 'manager@example.com',
        'password' => '123456',
        'remember_me' => '0'
      }
    }

    puts "3. Login response status: #{last_response.status}"
    puts "4. Location header: #{last_response.location}"

    # Check if login was successful
    if last_response.redirect?
      # Follow redirect
      follow_redirect!
      puts "5. After redirect status: #{last_response.status}"
      puts "6. Final URL path: #{last_request.path}"

      if last_request.path == '/' || last_request.path == '/dashboard' || last_request.path == '/bom'
        puts "\nSUCCESS: Login successful! Redirected to #{last_request.path}"
        puts "User logged in as: #{last_request.session.dig('warden.user.user.key')}"
      else
        puts "\nLogin failed or unexpected redirect to: #{last_request.path}"
        if last_response.body.include?('Invalid email or password')
          puts "Error: Invalid credentials"
        end
      end
    else
      puts "\nFAILED: No redirect after login attempt"
      if last_response.body.include?('Invalid email or password')
        puts "Error: Invalid credentials"
      end
      puts "Body preview: #{last_response.body[0..500]}"
    end
  end
end

LoginTest.new.run
