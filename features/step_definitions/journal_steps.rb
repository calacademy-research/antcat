# frozen_string_literal: true

Given("a journal exists with a name of {string}") do |name|
  create :journal, name: name
end
