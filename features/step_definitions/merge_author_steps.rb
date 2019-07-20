Given("the following names exist for an(other) author") do |table|
  author = create :author
  table.raw.each { |row| author.names.create! name: row.first }
end
