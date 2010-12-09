require Rails.root + 'spec/support/factories'

Given /the following entr(?:ies|y) exists? in the bibliography/ do |table|
  Place.create! :name => 'New York'
  table.hashes.each do |hash|
    @reference = Ward::Reference.new(hash).export
    Reference.connection.execute("UPDATE `references` SET updated_at = '#{hash[:updated_at]}' WHERE id = #{@reference.id}") if hash[:updated_at]
  end
  Reference.reindex
end

Given /the following entry nests it/ do |table|
  data = table.hashes.first
  @nestee_reference = @reference
  @reference = NestedReference.create! :author_names => [Factory(:author_name, :name => data[:authors])],
    :citation_year => data[:year], :title => data[:title], :pages_in => data[:pages_in],
    :nested_reference => @nestee_reference
  Reference.reindex
end

Given /that the entry has a source URL that's (not )?on our site/ do |is_not|
  hostname = is_not ? 'antbase.org' : 'antcat.org'
  @reference.update_attribute :source_url, "http://#{hostname}/article.pdf"
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
  selector = should_not ? :should_not : :should
  css_selector = "#reference_"
  css_selector << @reference.id.to_s if @reference
  find("#{css_selector} .reference_edit").send(selector, be_visible)
end

Then /there should not be an edit form/ do
  find("#reference_#{@reference.id} .reference_edit").should be_nil
end

Then /I should (not )?see a new edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  find("#reference_ .reference_edit").send(selector, be_visible)
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id} .reference_display").should_not be_visible
end

Then /"(.+)" should (not )?be visible/ do |text, should_not|
  text = find("*", :text => text)
  missing_or_invisible = text.nil? || !text.visible?
  missing_or_invisible.should(should_not ? be_true : be_false)
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
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

When /in the new edit form I follow "(.*?)"/ do |value|
  When "I follow \"#{value}\" within \"#reference_\""
end

When /in the new edit form I press the "(.*?)" button/ do |button|
  When "I press \"#{button}\" within \"#reference_\""
  sleep 0.5
end

When /in the new edit form I fill in "(.*?)" with the existing reference's ID/ do |field|
  When "in the new edit form I fill in \"#{field}\" with \"#{@reference.id}\""
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

Given 'I log in' do
  @user = Factory :user
  visit '/users/sign_in'
  And %{I fill in "user_email" with "#{@user.email}"}
  And %{I fill in "user_password" with "#{@user.password}"}
  And %{I press "Sign in"}
end

Given 'I am logged in' do
  @user = Factory :user
  visit '/stub_log_in'
end

Then 'I should not see the "Delete" button' do
  page.should_not have_css "button", :text => 'Delete'
end

Then /I should (not )?see a "PDF" link/ do |does_not|
  message = does_not ? :should_not : :should
  page.send(message, have_css("a", :text => 'PDF'))
end

When /^I press the "([^"]+)" button/ do |button|
  click_button button
  sleep 1
end

Then "I should see the reference's ID beside its label" do
  Then "I should see \"ID #{@reference.id}\""
end

When /I fill in "reference_nested_reference_id" with its own ID/ do
  When "I fill in \"reference_nested_reference_id\" with \"#{@reference.id}\""
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  Factory :unknown_reference, :id => 50000, :title => 'Dolerichoderinae'
end

When 'I choose a file to upload' do
  FakeWeb.register_uri(:put, "http://s3.amazonaws.com/antcat/sources/#{@reference.id}", :body => "OK")
  attach_file 'reference_source', Rails.root + 'features/21105.pdf'
end

Then 'I should see a link to that file' do
  find("a[href='http://localhost/sources/#{@reference.id}/21105.pdf']", :text => 'PDF').should_not be_nil
end
