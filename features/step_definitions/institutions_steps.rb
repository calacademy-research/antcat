Given(/^there is an institution "([^"]*)" \("([^"]*)"\)$/) do |abbreviation, name|
  create :institution, abbreviation: abbreviation, name: name
end
