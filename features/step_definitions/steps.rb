Then /^I (#{SHOULD_OR_SHOULD_NOT}) see an? "([^"]*)" button$/ do |should_selector, button|
  # TODO treat buttons and "button link" the same
  if button == "Edit"
    page.send(should_selector.to_sym, have_css("a.btn-edit"))
  else
    page.send(should_selector.to_sym, have_css("input[value='#{button}']"))
  end
end

Then /^there should be the HTML "(.*)"$/ do |html|
  body.should =~ /#{html}/
end

Then "I should not see any error messages" do
  page.should_not have_css '.error_messages li'
end

Given 'I will confirm on the next step' do
  begin
    evaluate_script("window.alert = function(msg) { return true; }")
    evaluate_script("window.confirm = function(msg) { return true; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^I press the "([^"]+)" button/ do |button|
  click_button button
end

When /^I click "([^"]*)"$/ do |selector|
  find(selector).click
end

When /I wait for a bit(?: more)?/ do
  sleep 1
end

And /I wait for a while/ do
  sleep 5
end

Then /^"([^"]+)" should be selected(?: in (.*))?$/ do |word, location|
  with_scope location || 'the page' do
    page.should have_css ".selected", :text => word
  end
end

When /I fill in the catalog search box with "(.*?)"/ do |search_term|
  find("#desktop-lower-menu #qq").set search_term
end
When /I press "Go" by the catalog search box/ do
  # TODO fix mobile
  within "#desktop-lower-menu" do
    step 'I press "Go"'
  end
end

When /I fill in the references search box with "(.*?)"/ do |search_term|
  within "#breadcrumbs" do
    step %{I fill in "q" with "#{search_term}"}
  end
end
When /I press "Go" by the references search box/ do
  within "#breadcrumbs" do
    step 'I press "Go"'
  end
end

When /I fill in the reference picker search box with "(.*?)"/ do |search_term|
  within ".antcat_reference_picker" do
    step %{I fill in "q" with "#{search_term}"}
  end
end
When /I press "Go" by the reference picker search box/ do
  within ".antcat_reference_picker" do
    step 'I press "Go"'
  end
end

Then /I should (not )?see "(.*?)" (?:with)?in (.*)$/ do |do_not, contents, location|
  with_scope location do
    step %{I should #{do_not}see "#{contents}"}
  end
end

Then(/^The taxon mouseover should contain "(.*?)"$/) do |arg1|
  find('.reference_key')['title'].should have_content(arg1)
end

Then /The parent name field should have "(.*?)"$/ do |contents|
  display_button = find('#parent_name_field .display_button')
  display_button.should have_selector(contents)
end

Then /I should see "([^"]*)" italicized/ do |italicized_text|
  page.should have_css('i', text: italicized_text)
end

And /I follow "(.*?)" (?:with)?in (.*)$/ do |link, location|
  with_scope location do
    step %{I follow "#{link}"}
  end
end

And /I press "(.*?)" (?:with)?in (.*)$/ do |button, location|
  with_scope location do
    step %{I press "#{button}"}
  end
end

And /I fill in "(.*?)" with "(.*?)" (?:with)?in (.*)$/ do |field, contents, location|
  with_scope location do
    step %{I fill in "#{field}" with "#{contents}"}
  end
end

Then "I should not see any search results" do
  page.should_not have_css "#search_results"
end

Then /^the page title should have "([^"]*)" in it$/ do |title|
  page.title.should have_content(title)
end

Then /^I should see a link "([^"]*)"$/ do |link|
  page.should have_css 'a', text: link
end

Given /that URL "([^"]*)" exists/ do |link|
  stub_request :any, link
end

When /^I reload the page$/ do
  visit current_path
end

When /^I follow "([^"]*)" inside the breadcrumb$/ do |link|
  within "#breadcrumbs" do
    step %{I follow "#{link}"}
  end
end
