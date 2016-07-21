Given /^a journal exists with a name of "([^"]*)"$/ do |name|
  create :journal, name: name
end

Given /^an author name exists with a name of "([^"]*)"$/ do |name|
  create :author_name, name: name
end
