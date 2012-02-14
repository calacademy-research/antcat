# coding: UTF-8
Then /^I (#{SHOULD_OR_SHOULD_NOT}) see a "([^"]*)" button$/ do |should_selector, button|
  page.send(should_selector.to_sym, have_css("input[value='#{button}']"))
end

And 'I debug' do
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

When /I wait for a bit(?: more)?/ do
  sleep 1
end

Then /^"([^"]+)" should be selected(?: in (.*))?$/ do |word, location|
  with_scope location || 'the page' do
    page.should have_css ".selected", :text => word
  end
end

When /I fill in the search box with "(.*?)"/ do |search_term|
  step %{I fill in "q" with "#{search_term}"}
end

When /I press "Go" by the search box/ do
  step 'I press "Go" within "#search_form"'
end

Then /I should (not )?see "(.*?)" (?:with)?in (.*)$/ do |do_not, contents, location|
  with_scope location do
    step %{I should #{do_not}see "#{contents}"}
  end
end

Then /I should see "([^"]*)" italicized/ do |italicized_text|
  page.should have_css('span.genus_or_species', :text => italicized_text)  
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

Then "I should be on an email form" do
  # no idea how to detect this
end
