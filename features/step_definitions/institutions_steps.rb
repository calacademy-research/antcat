Given("there is an institution {string} \({string}\)") do |abbreviation, name|
  create :institution, abbreviation: abbreviation, name: name
end
