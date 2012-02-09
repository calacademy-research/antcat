# coding: UTF-8
Given /the following user exists/ do |table|
  table.hashes.each {|hash| User.create! hash}
end

Given /^I fill in the email field with "([^"]+)"$/ do |string|
  step %{I fill in "user_email" with "#{string}"}
end

Given /^I fill in the password field with "([^"]+)"$/ do |string|
  step %{I fill in "user_password" with "#{string}"}
end

Given /^I press "([^"]+)" to log in$/ do |string|
  step %{I press "#{string}"}
end

Given 'I am not logged in' do
end

Given 'I log in' do
  step 'I go to the main page'
  User.delete_all
  @user = Factory :user, :email => 'mark@example.com'
  click_link "Login"
  step %{I fill in "user_email" with "#{@user.email}"}
  step %{I fill in "user_password" with "#{@user.password}"}
  step %{I press "Go" within "#login"}
end

Given 'I log out' do
  step %{I follow "Logout"}
end

Given 'I am logged in' do
  step 'I log in'
end

