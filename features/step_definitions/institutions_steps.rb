# frozen_string_literal: true

Given(/^there is an institution "([^"]*)" \("([^"]*)"\)$/) do |abbreviation, name|
  create :institution, abbreviation: abbreviation, name: name
end
