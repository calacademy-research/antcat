# frozen_string_literal: true

Given("there is a wiki page {string}") do |title|
  create :wiki_page, title: title
end
