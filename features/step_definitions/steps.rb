Given /the following entr(?:ies|y) exists? in the bibliography/ do |table|
  table.hashes.each do |hash|
    @reference = WardReference.new(hash).export
  end
end

Given /that the entry has a source URL/ do
  @reference.update_attribute :source_url, 'http://antbase.org/article.pdf'
end

Given /the following user exists/ do |table|
  table.hashes.each {|hash| User.create! hash}
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
  sleep 0.5
  selector = should_not ? :should_not : :should
  css_selector = "#reference_"
  css_selector << @reference.id.to_s if @reference
  find("#{css_selector} .reference_form").send(selector, be_visible)
end

Then /there should not be an edit form/ do
  find("#reference_#{@reference.id} .reference_form").should be_nil
end

Then /I should (not )?see a new edit form/ do |should_not|
  sleep 0.5
  selector = should_not ? :should_not : :should
  find("#reference_ .reference_form").send(selector, be_visible)
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id} .reference_display").should_not be_visible
end

Then /"(.+)" should not be visible/ do |text|
  text = find("*", :text => text)
  missing_or_invisible = text.nil? || !text.visible?
  missing_or_invisible.should be_true
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

Then "I should not see any error messages" do
  find('.error_messages li').should be_nil
end

When 'I click the reference' do
  sleep 0.5
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

Given 'I am not logged in' do
end

Given 'I am logged in' do
  email = 'mark@example.com'
  password = 'secret'
  User.create! :email => email, :password => password, :password_confirmation => password
  visit('/users/sign_in')
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Sign in"}
end

Then 'I should not see the "Delete" button' do
  page.should_not have_css "button", :text => 'Delete'
end

Then 'I should see a "PDF" link' do
  sleep 0.5
  page.should have_css "a", :text => 'PDF'
end
