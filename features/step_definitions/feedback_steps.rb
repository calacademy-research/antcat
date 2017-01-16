When(/^I click on the Feedback link$/) do
  find('[data-open="feedback_modal"]').click
end

When(/^I close the feedback form$/) do
  begin
    find("#feedback_modal .close-button").click
  rescue Capybara::Webkit::ClickFailed
    # Sometimes the close button is rendered outside of the screen.
    # So far I've only seen this is tests.
    $stdout.puts "Could not click on the modal's close button, clicking outside of it instead.".red
    click_outside_of_modal
  end
end

def click_outside_of_modal
  find(".reveal-overlay").click
end

Then(/^I should ?(not)? see the feedback form$/) do |should_or_not|
  if should_or_not == "not"
    step 'I should not see "Feedback and corrections are most"'
  else
    step 'I should see "Feedback and corrections are most"'
  end
end

Then(/^the (name|email|comment|page) field within the feedback form should contain "([^"]*)"$/) do |field, value|
  expect(find("#feedback_#{field}").value).to include value
end

Given(/^I have already posted 3 feedbacks in the last 5 minutes$/) do
  3.times { create :feedback }
end

Then(/^I pretend to be a bot by filling in the invisible work email field$/) do
  page.execute_script "$('#feedback_work_email').val('spammer@bots.ru');"
end

Given(/^a visitor has submitted a feedback with the comment "([^"]*)"$/) do |comment|
  cheat_and_set_user_for_feed
  create :feedback, comment: comment
end

Given(/^a visitor has submitted a feedback$/) do
  step %{a visitor has submitted a feedback with the comment "Cool."}
end

Given(/^there is a closed feedback item with the comment "([^"]*)"$/) do |comment|
  create :feedback, comment: comment, open: false
end

Given(/^there is a (?:closed )?feedback item$/) do
  step %{there is a closed feedback item with the comment "Cool."}
end
