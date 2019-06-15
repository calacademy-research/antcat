When("I click on the Feedback link") do
  first('#feedback-button').click
end

When("I close the feedback form") do
  find("#feedback_modal .close-button").click
end

Then(/^I should not see the feedback form$/) do
  expect(page).to have_css '#submit-feedback-js', visible: false
end

Then(/^I should see the feedback form$/) do
  expect(page).to have_css '#submit-feedback-js', visible: true
end

Then(/^the (name|email|comment|page) field within the feedback form should contain "([^"]*)"$/) do |field, value|
  expect(find("#feedback_#{field}").value).to include value
end

Given("I have already posted 5 feedbacks in the last 5 minutes") do
  5.times { create :feedback }
end

Then("I pretend to be a bot by filling in the invisible work email field") do
  page.execute_script "$('#feedback_work_email').val('spammer@bots.ru');"
end

Given("a visitor has submitted a feedback with the comment {string}") do |comment|
  cheat_and_set_user_for_feed
  feedback = create :feedback, comment: comment
  feedback.create_activity :create
end

Given("a visitor has submitted a feedback") do
  step 'a visitor has submitted a feedback with the comment "Cool."'
end

Given("there is a closed feedback item with the comment {string}") do |comment|
  create :feedback, comment: comment, open: false
end

Given("there is a (closed )feedback item") do
  step 'there is a closed feedback item with the comment "Cool."'
end
