# frozen_string_literal: true

Given("an author name exists with a name of {string}") do |name|
  create :author_name, name: name
end

Given("the following names exist for an(other) author") do |table|
  author = create :author
  table.raw.each { |row| author.names.create!(name: row.first) }
end

When("I set author_to_merge_id to the ID of {string}") do |author_name|
  author = AuthorName.find_by!(name: author_name).author
  find('#author_to_merge_id', visible: false).set author.id # HACK.
end
