Given /the following entr(?:ies|y) exists? in the bibliography/ do |table|
  table.hashes.each {|hash| @reference = Reference.create! hash}
end

Then 'I should see these entries in this order:' do |entries|
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + 1}) td", :text => e['entry']
  end
end

Then /I should see "([^"]*)" in italics/ do |italicized_text|
  page.should have_css('span.taxon', :text => italicized_text)  
end

Then /^there should be the HTML "(.*)"$/ do |html|
  body.should =~ /#{html}/
end

Then /I should (not )?see the edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  find("#reference_#{@reference.id} .reference_form").send(selector, be_visible)
end

Then /I should (not )?see a new edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  find("#reference_ .reference_form").send(selector, be_visible)
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id} .reference_display").should_not be_visible
end

Then '"Add reference" should not be visible' do
  find_link('Add reference').should_not be_visible
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

Then /"(.*?)" should be marked as an error/ do |id|
  find(".fieldWithErrors ##{id}").should_not be_nil
end

Then "I should not see any error messages" do
  find('.error_messages li').should be_nil
end

When 'I click the reference' do
  find("#reference_#{@reference.id} .reference_display").click
end

When /in the new edit form I fill in "(.*?)" with "(.*?)"/ do |field, value|
  When "I fill in \"#{field}\" with \"#{value}\" within \"#reference_\""
end

When /in the new edit form I press "(.*?)"/ do |button|
  When "I press \"#{button}\" within \"#reference_\""
end

Given 'I will confirm on the next step' do
  begin
    evaluate_script("window.alert = function(msg) { return true; }")
    evaluate_script("window.confirm = function(msg) { return true; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then 'I should not see a "Delete" button' do
  find('button', :text => 'Delete').should be_nil
end
