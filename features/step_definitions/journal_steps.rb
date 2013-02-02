# coding: UTF-8

Given /^a journal exists with a name of "([^"]*)"$/ do |name|
  FactoryGirl.create :journal, name: name
end

Given /^an author name exists with a name of "([^"]*)"$/ do |name|
  FactoryGirl.create :author_name, name: name
end
