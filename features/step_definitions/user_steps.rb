# coding: UTF-8
Given /^I fill in the email field with "([^"]+)"$/ do |string|
  step %{I fill in "user_email" with "#{string}"}
end

Given /^I fill in the password field with "([^"]+)"$/ do |string|
  step %{I fill in "user_password" with "#{string}"}
end

Given /^I press "([^"]+)" to log in$/ do |string|
  step %{I press "#{string}"}
end
