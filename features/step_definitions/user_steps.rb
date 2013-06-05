# coding: UTF-8

Given /this user exists/ do |table|
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

def login can_edit_catalog, use_web_interface = false
  step 'I go to the main page'
  User.delete_all
  attributes = {email: 'mark@example.com'}
  attributes[:can_edit_catalog] = true if can_edit_catalog
  @user = FactoryGirl.create :user, attributes

  use_web_interface ? login_through_web_page : login_programmatically
end

def login_programmatically
  login_as @user
end

def login_through_web_page
  click_link "Login"
  step %{I fill in "user_email" with "#{@user.email}"}
  step %{I fill in "user_password" with "#{@user.password}"}
  step %{I press "Go" within "#login"}
end

Given /^I log in$/ do
  login true
end
Given /^I log in as a bibliography editor$/ do
  login false
end
Given /^I log in through the web interface/ do
  login true, true
end

Given 'I log out' do
  step %{I follow "Logout"}
end

Given 'I am logged in' do
  step 'I log in'
end
