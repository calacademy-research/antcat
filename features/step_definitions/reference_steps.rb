# coding: UTF-8
Given /^the following references? exists?$/ do |table|
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
end

Given /^the following references? match(?:es)? that Bolton reference$/ do |table|
  table.hashes.each do |hash|
    similarity = hash.delete 'similarity'
    Factory :bolton_match, :reference => Factory(:article_reference, hash), :bolton_reference => @bolton_reference, :similarity => similarity
  end
end

# cf. bolton_references.sass
CSS_CLASSES = {'green' => 'auto', 'red' => 'none', 'darkgreen' => 'manual', 'darkred' => 'unmatchable'}

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
end

def set_timestamps reference, hash
  Reference.connection.execute("UPDATE `references` SET updated_at = '#{hash[:updated_at]}' WHERE id = #{reference.id}") if hash[:updated_at]
  Reference.connection.execute("UPDATE `references` SET created_at = '#{hash[:created_at]}' WHERE id = #{reference.id}") if hash[:created_at]
end

Given /the following entry nests it/ do |table|
  data = table.hashes.first
  @nestee_reference = @reference
  @reference = NestedReference.create! :author_names => [Factory(:author_name, :name => data[:authors])],
    :citation_year => data[:year], :title => data[:title], :pages_in => data[:pages_in],
    :nested_reference => @nestee_reference
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

Then /I should see these entries (with a header )?in this order:/ do |with_header, entries|
  offset = with_header ? 2 : 1
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['entry']
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['date']
  end
end

Then /I (#{SHOULD_OR_SHOULD_NOT}) see the edit form/ do |should_selector|
  css_selector = "#reference_"
  css_selector << @reference.id.to_s if @reference
  find("#{css_selector} .reference_edit").send should_selector.to_sym, be_visible
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

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

When /in the new edit form I fill in "(.*?)" with "(.*?)"/ do |field, value|
  within "#reference_" do
    step "I fill in \"#{field}\" with \"#{value}\""
  end
end

Then /in the new edit form the "(.*?)" field (#{SHOULD_OR_SHOULD_NOT}) contain "(.*?)"/ do |field, should_or_should_not, value|
  within "#reference_" do
    step %{the "#{field}" field #{should_or_should_not} contain "#{value}"}
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

Then 'the "Delete" button should not be visible' do
  find_button('Delete').should_not be_visible
end

Then 'I should not see the "Delete" button' do
  page.should_not have_css "button", :text => 'Delete'
end

Then 'all the buttons should be disabled' do
  disabled = page.all('.margin .button_to input[disabled=disabled][type=submit]')
  all = page.all('.margin .button_to input[type=submit]')
  disabled.size.should == all.size
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

When 'I choose a file to upload' do
  stub_request(:put, "http://s3.amazonaws.com/antcat/1/21105.pdf")
  attach_file 'reference_document_attributes_file', Rails.root + 'features/support/21105.pdf'
end

Then 'I should see a link to that file' do
  @reference.should_not be_nil
  @reference.reload.document.should_not be_nil
  page.should have_css("a[href='http://127.0.0.1/documents/#{@reference.document.id}/21105.pdf']", :text => 'PDF')
end

Then 'I should be redirected to Amazon' do
end

And /I (edit|delete|copy) "(.*?)"/ do |verb, author|
  reference = Reference.where('author_names_string_cache like ?', "%#{author}%").first
  step %{I follow "#{verb}" within "#reference_#{reference.id}"}
end

Then /I should (not )?see the "add" icon/ do |do_not|
  selector = do_not ? :should_not : :should
  find("img[alt=add]").send selector, be_visible
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

Given /^I will enter the ID of "Arbitrary Match" in the following dialog$/ do
  id = Reference.find_by_title("Arbitrary Match").id
  page.evaluate_script 'window.original_prompt_function = window.prompt;'
  page.evaluate_script "window.prompt = function(msg) { return '#{id}'; }"
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = Factory :unknown_reference, :title => 'Dolerichoderinae'
  sql = "UPDATE `references` SET id = 50000 WHERE id = #{reference.id}"
  ActiveRecord::Base.connection.execute sql
end
