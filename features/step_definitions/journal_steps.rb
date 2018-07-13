Given("a journal exists with a name of {string}") do |name|
  create :journal, name: name
end

Given("an author name exists with a name of {string}") do |name|
  create :author_name, name: name
end
