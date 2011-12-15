# coding: UTF-8

Given /the following references? exists?/ do |table|
  Reference.delete_all
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    hash.merge! :journal => Factory(:journal, :name => matches[1]), :series_volume_issue => matches[2],
      :pagination => matches[3]
    create_reference :article_reference, hash
  end
end

Given /the following Bolton references? exists?/ do |table|
  table.hashes.each do |hash|
    hash.delete('match_status') if hash['match_status'].blank?
    @bolton_reference = Factory :bolton_reference, hash
  end
  Bolton::Reference.reindex
end

Given /^the following references? match(?:es)? that Bolton reference$/ do |table|
  table.hashes.each do |hash|
    similarity = hash.delete 'similarity'
    Factory :bolton_match, :reference => Factory(:article_reference, hash), :bolton_reference => @bolton_reference, :similarity => similarity
  end
end

# cf. bolton_references.sass
CSS_CLASSES = {'green' => 'auto', 'red' => 'none', 'darkgreen' => 'manual', 'darkred' => 'unmatcheable'}

Then /^the Bolton reference should be (.+)$/ do |color|
  css_class = CSS_CLASSES[color]
  page.should have_css ".bolton_reference.#{css_class}"
end

Then /^the (?:matched )?reference should be (.+)$/ do |color|
  if color == 'white'
    page.should have_css ".match"
  else
    css_class = CSS_CLASSES[color]
    page.should have_css ".match.#{css_class}"
  end
end

Then /^I should( not)? see a "([^"]+)" button$/ do |should_not, button|
  selector = should_not ? :should_not : :should
  page.send(selector, have_css("input[value='#{button}']"))
end

Given /the following book references? exists?/ do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/
    hash.merge! :publisher => Factory(:publisher, :name => matches[2],
                                      :place => Factory(:place, :name => matches[1])),
                :pagination => matches[3]
    create_reference :book_reference, hash
  end
end

Given /the following unknown references? exists?/ do |table|
  table.hashes.each do |hash|
    create_reference :unknown_reference, hash
  end
end

def create_reference type, hash
  author = hash.delete('author')
  if author
    author_names = [Factory(:author_name, :name => author)]
  else
    authors = hash.delete('authors')
    author_names = AuthorParser.parse(authors)[:names]
    author_names_suffix = AuthorParser.parse(authors)[:suffix]
    author_names = author_names.inject([]) do |author_names, author_name|
      author_name = AuthorName.find_by_name(author_name) || Factory(:author_name, :name => author_name)
      author_names << author_name
    end
  end

  hash[:citation_year] = hash.delete 'year'
  reference = Factory type, hash.merge(:author_names => author_names, :author_names_suffix => author_names_suffix)
  @reference ||= reference
  set_timestamps reference, hash
  Reference.reindex
end

def set_timestamps reference, hash
  Reference.connection.execute("UPDATE `references` SET updated_at = '#{hash[:updated_at]}' WHERE id = #{reference.id}") if hash[:updated_at]
  Reference.connection.execute("UPDATE `references` SET created_at = '#{hash[:created_at]}' WHERE id = #{reference.id}") if hash[:created_at]
end

Given 'the following species exist' do |table|
  table.hashes.each do |hash|
    Factory :species, hash
  end
end

And 'I debug' do
end 

Given /the following entry nests it/ do |table|
  data = table.hashes.first
  @nestee_reference = @reference
  @reference = NestedReference.create! :author_names => [Factory(:author_name, :name => data[:authors])],
    :citation_year => data[:year], :title => data[:title], :pages_in => data[:pages_in],
    :nested_reference => @nestee_reference
  Reference.reindex
end

Given /that the entry has a URL that's on our site( that is public)?/ do |is_public|
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attributes :url => "localhost/documents/#{@reference.document.id}/123.pdf",
                                        :file_file_name => '123.pdf',
                                        :public => is_public ? true : nil
end

Given /that the entry has a URL that's not on our site/ do
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attribute :url,  'google.com/foo'
end

Given /the following user exists/ do |table|
  table.hashes.each {|hash| User.create! hash}
end

Then /I should see these entries (with a header )?in this order:/ do |with_header, entries|
  offset = with_header ? 2 : 1
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['entry']
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['date']
  end
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

Then /I should not be editing/ do
  step %{I should see "edit"}
end

Then /I should see a new edit form/ do
  find("#reference_ .reference_edit").should be_visible
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id} .reference_display").should_not be_visible
end

Then /the "(.+)" link should (not )?be visible/ do |text, should_not|
  find_link(text).visible?.should == !should_not
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

Then "I should not see any error messages" do
  page.should_not have_css '.error_messages li'
end

When /in the new edit form I fill in "(.*?)" with "(.*?)"/ do |field, value|
  within "#reference_" do
    step "I fill in \"#{field}\" with \"#{value}\""
  end
end

Then /in the new edit form the "(.*?)" field should (not )?contain "(.*?)"/ do |field, should_not, value|
  within "#reference_" do
    step %{the "#{field}" field should #{should_not ? 'not ' : ''}contain "#{value}"}
  end
end

When /in the new edit form I follow "(.*?)"/ do |value|
  step "I follow \"#{value}\" within \"#reference_\""
end

When /in the new edit form I press the "(.*?)" button/ do |button|
  step "I press \"#{button}\" within \"#reference_\""
end

Then /there should not be an edit form/ do
  page.should have_no_css "#reference_#{@reference.id} .reference_edit"
end

When /in the new edit form I fill in "(.*?)" with the existing reference's ID/ do |field|
  step "in the new edit form I fill in \"#{field}\" with \"#{@reference.id}\""
end

Given 'I will confirm on the next step' do
  begin
    evaluate_script("window.alert = function(msg) { return true; }")
    evaluate_script("window.confirm = function(msg) { return true; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then 'the "Delete" button should not be visible' do
  find_button('Delete').should_not be_visible
end

Then 'all the buttons should be disabled' do
  disabled = page.all('.margin .button_to input[disabled=disabled][type=submit]')
  all = page.all('.margin .button_to input[type=submit]')
  disabled.size.should == all.size
end

Given 'I am not logged in' do
end

Given 'I log in' do
  step 'I go to the main page'
  User.delete_all
  @user = Factory :user
  click_link "Login"
  step %{I fill in "user_email" with "#{@user.email}"}
  step %{I fill in "user_password" with "#{@user.password}"}
  step %{I press "Go" within "#login"}
end

Given 'I log out' do
  step %{I follow "Logout"}
end

Given 'I am logged in' do
  step 'I log in'
end

Then 'I should not see the "Delete" button' do
  page.should_not have_css "button", :text => 'Delete'
end

Then /I should (not )?see a "PDF" link/ do |should_not|
  begin
    trace = ['Inside the I should(not) see a PDF step']
    page_has_no_selector = page.has_no_selector?('a', :text => 'PDF')
    trace << 'after page.has_no_selector'
    unless page_has_no_selector and should_not
      trace << 'inside unless'
      find_link("PDF").send(should_not ? :should_not : :should, be_visible)
      trace << 'after find_link'
    end
    trace << 'end'

  rescue Exception
    raise
  end
end

When /^I press the "([^"]+)" button/ do |button|
  click_button button
end

Then "I should see the reference's ID beside its label" do
  step "I should see \"ID #{@reference.id}\""
end

When /I fill in "reference_nested_reference_id" with its own ID/ do
  step "I fill in \"reference_nested_reference_id\" with \"#{@reference.id}\""
end

When /I fill in "([^"]*)" with a URL to a document that exists/ do |field|
  stub_request :any, "google.com/foo"
  step "I fill in \"#{field}\" with \"google\.com/foo\""
end

When /I fill in "([^"]*)" with a URL to a document that doesn't exist/ do |field|
  stub_request(:any, "google.com/foo").to_return :status => 404
  step "I fill in \"#{field}\" with \"google\.com/foo\""
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = Factory :unknown_reference, :title => 'Dolerichoderinae'
  sql = "UPDATE `references` SET id = 50000 WHERE id = #{reference.id}"
  ActiveRecord::Base.connection.execute sql
end

When 'I choose a file to upload' do
  stub_request(:put, "http://s3.amazonaws.com/antcat/1/21105.pdf")
  attach_file 'reference_document_attributes_file', Rails.root + 'features/support/21105.pdf'
end

Then 'I should see a link to that file' do
  @reference.should_not be_nil
  @reference.reload.document.should_not be_nil
  page.should have_css("a[href='http://127.0.0.1/documents/#{@reference.document.id}/21105.pdf']", :text => 'PDF')
end

When /I wait for a bit(?: more)?/ do
  sleep 1
end

Then 'I should be redirected to Amazon' do
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

When /I follow "All" in the subfamilies list/ do
  step %{I follow "All" within ".subfamilies"}
end

Then /^"([^"]+)" should be selected(?: in (.*))?$/ do |word, location|
  with_scope location || 'the page' do
    page.should have_css ".selected", :text => word
  end
end

And /I (edit|delete|copy) "(.*?)"/ do |verb, author|
  reference = Reference.where('author_names_string_cache like ?', "%#{author}%").first
  step %{I follow "#{verb}" within "#reference_#{reference.id}"}
end

Given /a subfamily exists with a name of "(.*?)" and a taxonomic history of "(.*?)"/ do |taxon_name, taxonomic_history|
  Factory :subfamily, :name => taxon_name, :taxonomic_history => taxonomic_history
end

Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  Factory :tribe, :name => taxon_name, :subfamily => subfamily, :taxonomic_history => taxonomic_history
end

Given /a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  Factory :genus, :name => taxon_name, :subfamily => subfamily, :tribe => nil, :taxonomic_history => taxonomic_history, :status => status
end

Given /a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, taxonomic_history|
  genus = Factory :genus, :name => taxon_name, :subfamily => nil, :tribe => nil, :taxonomic_history => taxonomic_history
end

Given /a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |fossil, taxon_name, parent_name, taxonomic_history|
  tribe = Tribe.find_by_name(parent_name)
  Factory :genus, :name => taxon_name, :subfamily => tribe.subfamily, :tribe => tribe, :taxonomic_history => taxonomic_history, :fossil => fossil.present?
end

Given /a genus that was replaced by "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |replacement, name, taxonomic_history|
  replacement = Genus.find_by_name(replacement) || Factory(:genus, :name => replacement)
  Factory :genus, :name => name, :taxonomic_history => taxonomic_history, :status => 'homonym', :subfamily => replacement.subfamily, :homonym_replaced_by => replacement
end

Given /a genus that was synonymized to "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |senior_synonym, name, taxonomic_history|
  senior_synonym = Genus.find_by_name(senior_synonym) || Factory(:genus, :name => senior_synonym)
  Factory :genus, :name => name, :taxonomic_history => taxonomic_history, :status => 'synonym', :subfamily => senior_synonym.subfamily, :synonym_of => senior_synonym
end

Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  genus = Genus.find_by_name(parent_name) || Factory(:genus, :name => parent_name)
  Factory :species, :name => taxon_name, :genus => genus, :taxonomic_history => taxonomic_history
end

When /I fill in the match threshold with "(.*?)"/ do |match_threshold|
  step %{I fill in "match_threshold" with "#{match_threshold}"}
end

When /I fill in the search box with "(.*?)"/ do |search_term|
  step %{I fill in "q" with "#{search_term}"}
end

When /I press "Go" by the search box/ do
  step 'I press "Go" within "#search_form"'
end

Then /I should (not )?see the "add" icon/ do |do_not|
  selector = do_not ? :should_not : :should
  find("img[alt=add]").send selector, be_visible
end

Then /I should (not )?see "(.*?)" (?:with)?in (.*)$/ do |do_not, contents, location|
  with_scope location do
    step %{I should #{do_not}see "#{contents}"}
  end
end

Then /the browser header should be "(.*?)"/ do |contents|
  words = contents.split ' '
  page.should have_css '#browser .header .taxon_header', :text => words.first
  page.should have_css '#browser .header .taxon_header span', :text => words.second
end

Then /I should not see "(.*?)" by itself in the browser/ do |contents|
  page.should_not have_css('.taxon_header a', :text => contents)
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

Then /"(.*?)" tab should be selected/ do |tab|
  page.should have_css ".catalog_view_selector input[checked=checked][value=#{tab}]"
end

Then /I should be in "(.*?)" mode/ do |mode|
  step %{the "#{mode}" tab should be selected}
end

very_long_author_names_string = (0...26).inject([]) {|a, n| a << "AuthorWithVeryVeryVeryLongName#{(?A.ord + n).chr}, A."}.join('; ')

When /in the new edit form I fill in "reference_author_names_string" with a very long author names string/ do
  within "#reference_" do
    step %{I fill in "reference_author_names_string" with "#{very_long_author_names_string}"}
  end
end

Then /I should see a very long author names string/ do
  step %{I should see "#{very_long_author_names_string}"}
end

And /I hide tribes/ do
  step %{I follow "hide"}
end

Then "I should not see any search results" do
  page.should_not have_css "#search_results"
end
