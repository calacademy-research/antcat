When /^I click on the Feedback link$/ do
  find('[data-open="feedback_modal"]').click
end

When(/^I close the feedback form$/) do
  find("#feedback_modal .close-button").click
end

Then /^I should ?(not)? see the feedback form$/ do |should_or_not|
  if should_or_not == "not"
    step 'I should not see "Feedback and corrections are most"'
  else
    step 'I should see "Feedback and corrections are most"'
  end
end

Then /^the (name|email|comment|page) field within the feedback form should contain "([^"]*)"$/ do |field, value|
  expect(page.find("#feedback_#{field}").value).to include value
end

Given /^I have already posted 3 feedbacks in the last 5 minutes$/ do
  3.times { FactoryGirl.create :feedback }
end

Then /^I pretend to be a bot by filling in the invisible work email field$/ do
  page.execute_script "$('#feedback_work_email').val('spammer@bots.ru');"
end

Given /^a visitor has submitted a feedback with the comment "([^"]*)"$/ do |comment|
  FactoryGirl.create :feedback, comment: comment
end

Given /^there is a closed feedback item with the comment "([^"]*)"$/ do |comment|
  FactoryGirl.create :feedback, comment: comment, open: false
end

Given /^the editors Archibald and Batiatus \(but not Flint\) have enabled feedback email forwarding$/ do
  FactoryGirl.create :editor, name: "Archibald",
    email: "archibald@antcat.org", receive_feedback_emails: true
  FactoryGirl.create :editor, name: "Batiatus",
    email: "batiatus@antcat.org", receive_feedback_emails: true

  FactoryGirl.create :editor, name: "Flint",
    email: "flint@antcat.org"
end

When /^follow the link of the first feedback$/ do
  first("table.feedbacks a", text: "Details").click
end
