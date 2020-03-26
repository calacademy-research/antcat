# frozen_string_literal: true

Then(/^the page field within the feedback form should contain "([^"]*)"$/) do |value|
  expect(find("#feedback_page").value).to include value
end

Given("a visitor has submitted a feedback") do
  create :feedback, user: nil
end

Given("there is a closed feedback item") do
  create :feedback, open: false
end
