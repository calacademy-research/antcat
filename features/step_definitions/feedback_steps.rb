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

Then /^the email should contain "([^"]*)"$/ do |text|
  within_frame(find("iframe")) do
    step %Q[I should see "#{text}"]
  end
end
