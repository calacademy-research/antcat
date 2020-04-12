# frozen_string_literal: true

Given("there is an open issue {string}") do |title|
  create :issue, :open, title: title, user: User.first
end
