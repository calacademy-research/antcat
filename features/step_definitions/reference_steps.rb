Given /^(?:this|these) references? exists?$/ do |table|
  Reference.delete_all


  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    journal = FactoryGirl.create :journal, name: matches[1]
    hash.merge! journal: journal, series_volume_issue: matches[2], pagination: matches[3]
    create_reference :article_reference, hash
  end
end

Given /^(?:this|these) dated references? exists?$/ do |table|
  Reference.delete_all
  table.map_column!('created_at') do |date|
    if date == 'TODAYS_DATE'
      date = Time.now.strftime("%Y-%m-%d")
    elsif date == 'YESTERDAYS_DATE'
      t=Time.now
      yesterday=t-1.day

      date = yesterday.strftime("%Y-%m-%d")
    end
    date
  end

  table.map_column!('updated_at') do |date|
    if date == 'TODAYS_DATE'
      date = Time.now.strftime("%Y-%m-%d")
    end
    date
  end

  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    journal = FactoryGirl.create :journal, name: matches[1]
    hash.merge! journal: journal, series_volume_issue: matches[2], pagination: matches[3]
    create_reference :article_reference, hash
  end
end

Given /(?:these|this) Bolton references? exists?/ do |table|
  table.hashes.each do |hash|
    hash.delete('match_status') if hash['match_status'].blank?
    @bolton_reference = FactoryGirl.create :bolton_reference, hash
  end
end

Given /^the following references? match(?:es)? that Bolton reference$/ do |table|
  table.hashes.each do |hash|
    similarity = hash.delete 'similarity'
    FactoryGirl.create :bolton_match, :reference => FactoryGirl.create(:article_reference, hash), :bolton_reference => @bolton_reference, :similarity => similarity
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

Given /(?:these|this) book references? exists?/ do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/
    hash.merge! :publisher => FactoryGirl.create(:publisher, :name => matches[2],
                                                 :place => FactoryGirl.create(:place, :name => matches[1])),
                :pagination => matches[3]
    create_reference :book_reference, hash
  end
end

Given(/(?:these|this) unknown references? exists?/) do |table|
  table.hashes.each do |hash|
    create_reference :unknown_reference, hash
  end
end

def create_reference type, hash
  author = hash.delete('author')
  if author
    author_names = [FactoryGirl.create(:author_name, :name => author)]
  else
    authors = hash.delete('authors')
    author_names = Parsers::AuthorParser.parse(authors)[:names]
    author_names_suffix = Parsers::AuthorParser.parse(authors)[:suffix]
    author_names = author_names.inject([]) do |author_names, author_name|
      author_name = AuthorName.find_by_name(author_name) || FactoryGirl.create(:author_name, :name => author_name)
      author_names << author_name
    end
  end

  hash[:year] = hash.delete('year').to_i
  hash[:citation_year] =
    if hash[:citation_year].present?
      hash.delete('citation_year').to_s
    else
      hash[:year].to_s
    end

  reference = FactoryGirl.create type, hash.merge(:author_names => author_names, :author_names_suffix => author_names_suffix)
  @reference ||= reference
  set_timestamps reference, hash
  reference
end

def set_timestamps reference, hash
  reference.update_column :updated_at, hash[:updated_at] if hash[:updated_at]
  reference.update_column :created_at, hash[:created_at] if hash[:created_at]
end

Given /the following entry nests it/ do |table|
  data = table.hashes.first
  @nestee_reference = @reference
  @reference = NestedReference.create! :author_names => [FactoryGirl.create(:author_name, :name => data[:authors])],
                                       :citation_year => data[:year], :title => data[:title], :pages_in => data[:pages_in],
                                       nesting_reference: @nestee_reference
end

Given /that the entry has a URL that's on our site( that is public)?/ do |is_public|
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attributes :url => "localhost/documents/#{@reference.document.id}/123.pdf",
                                        :file_file_name => '123.pdf',
                                        :public => is_public ? true : nil
end

Given /that the entry has a URL that's not on our site/ do
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attribute :url, 'google.com/foo'
end

Then /I should see these entries (with a header )?in this order:/ do |with_header, entries|
  offset = with_header ? 2 : 1
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['entry']
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['date']
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['review_state']
  end
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

##################

Then /I (#{SHOULD_OR_SHOULD_NOT}) see the edit form/ do |should_selector|
  css_selector = "#reference_"
  css_selector << @reference.id.to_s if @reference
  find("#{css_selector} .reference_edit").send should_selector.to_sym, be_visible
end

Then /I should not be editing/ do
  # TODO Rails 4 upgrade - this isn't working. Verified manually.
  within first('.icons') do
    page.should have_css('img[alt=edit]')
  end
end

Then /I should see a new edit form/ do
  within first("#reference_") do
    find(".reference_edit").should be_visible
  end
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id}",visible: false).should_not be_visible
end

When /in the new edit form I fill in "(.*?)" with "(.*?)"/ do |field, value|
  within first("#reference_") do
    step "I fill in \"#{field}\" with \"#{value}\""
  end
end

When /in the new edit form I fill in "reference_nesting_reference_id" with the ID for "(.*?)"$/ do |title|
  reference = Reference.find_by_title title
  within first("#reference_") do
    step "I fill in \"reference_nesting_reference_id\" with \"#{reference.id}\""
  end
end

Then /in the new edit form the "(.*?)" field (#{SHOULD_OR_SHOULD_NOT}) contain "(.*?)"/ do |field, should_or_should_not, value|
  within first("#reference_") do
    step %{the "#{field}" field #{should_or_should_not} contain "#{value}"}
  end
end

When /in the new edit form I follow "(.*?)"/ do |value|
  within first("#reference_") do
    step "I follow \"#{value}\""
  end
end

When /in the new edit form I press the "(.*?)" button/ do |button|
  within first("#reference_") do
    step "I press \"#{button}\""
  end
end

Then /there should not be an edit form/ do
  page.should have_no_css "#reference_#{@reference.id} .reference_edit"
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

When /I fill in "reference_nesting_reference_id" with its own ID$/ do
  within first('.reference') do
    step "I fill in \"reference_nesting_reference_id\" with \"#{@reference.id}\""
  end
end

When /I fill in "([^"]*)" with a URL to a document that exists/ do |field|
  stub_request :any, "google.com/foo"
  within first('.reference') do
    step "I fill in \"#{field}\" with \"google\.com/foo\""
  end
end

When /I fill in "([^"]*)" with a URL to a document that doesn't exist/ do |field|
  stub_request(:any, "google.com/foo").to_return :status => 404
  within first('.reference') do
    step "I fill in \"#{field}\" with \"google\.com/foo\""
  end
end

And /I (edit|delete) "(.*?)"/ do |verb, author|
  reference = Reference.where('author_names_string_cache like ?', "%#{author}%").first
  step %{I follow "#{verb}" within "#reference_#{reference.id}"}
end

Then /I should (not )?see the "add" icon/ do |do_not|
  selector = do_not ? :should_not : :should
  find("img[alt=add]").send selector, be_visible
end

very_long_author_names_string = (0...26).inject([]) { |a, n| a << "AuthorWithVeryVeryVeryLongName#{(?A.ord + n).chr}, A." }.join('; ')

When /in the new edit form I fill in "reference_author_names_string" with a very long author names string/ do
  within first("#reference_") do
    step %{I fill in "reference_author_names_string" with "#{very_long_author_names_string}"}
  end
end

When /in the edit form I fill in "([^"]*)" with "([^"]*)"/ do |field, text|
  within "#reference_#{@reference.id}" do
    step %{I fill in "#{field}" with "#{text}"}
  end
end
Then /I should see a very long author names string/ do
  step %{I should see "#{very_long_author_names_string}"}
end

When /^I click the "edit" link beside the reference$/ do
  within "#reference_#{@reference.id}" do
    step %{I follow "edit"}
  end
end

When /^In the edit form, I press the "Save" button$/ do
  within "#reference_#{@reference.id}" do
    step %{I press the "Save" button}
  end
end

Given /^I will enter the ID of "Arbitrary Match" in the following dialog$/ do
  id = Reference.find_by_title("Arbitrary Match").id
  page.evaluate_script 'window.original_prompt_function = window.prompt;'
  page.evaluate_script "window.prompt = function(msg) { return '#{id}'; }"
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = FactoryGirl.create :unknown_reference, :title => 'Dolerichoderinae'
  reference.update_column :id, 50000
end

Given /^there is a missing reference(?: with citation "(.+)")?( in a protonym)?$/ do |citation, in_protonym|
  citation ||= 'Adventures among Ants'
  missing_reference = FactoryGirl.create :missing_reference, citation: citation
  if in_protonym
    FactoryGirl.create :protonym, authorship: FactoryGirl.create(:citation, reference: missing_reference)
  end
end

Given /^I click "replace" in the first row of missing references$/ do
  first('#missing_references a.replace_link').click
end

And /^I click the replacement field$/ do
  step %{I click "#replacement_id_field .display_button"}
end

And /^I should not see the missing reference$/ do
  step 'I should not see "Adventures among Ants"'
end

Given /there are no references/ do
  Reference.delete_all
end

When /^I save my changes to the first reference$/ do
  within first('.reference') do
    step 'I save my changes'
  end
end

# New references list
When /^I click "(.*?)" on the Ward reference$/ do |button|
  # TODO ".reference_row" has been removed
  within find(".reference_row", :text => 'Ward') do
    step %{I press "#{button}"}
  end
end
Then /^the review status on the Ward reference should change to "(.*?)"$/ do |status|
  # TODO ".reference_row" has been removed
  within find(".reference_row", :text => 'Ward') do
    step %{I should see "#{status}"}
  end
end
Then /^it (#{SHOULD_OR_SHOULD_NOT}) show "(.*?)" as the default$/ do |should_selector, key|
  reference = find_reference_by_key key
  author = key.split(' ').first
  # TODO ".reference_row" has been removed
  within find(".reference_row", text: author) do
    step %{I #{should_selector} see "Default"}
  end
end

def find_reference_by_key key
  parts = key.split(' ')
  last_name = parts[0]
  year = parts[1]
  Reference.where(principal_author_last_name_cache: last_name, year: year.to_i).first
end

And /^the default reference is "([^"]*)"$/ do |key|
  reference = find_reference_by_key key
  DefaultReference.stub(:get).and_return reference
end
And /^there is no default reference$/ do
  DefaultReference.stub(:get).and_return nil
end

Given /^there is a taxon with that reference as its protonym's reference$/ do
  taxon = create_genus
  taxon.protonym.authorship.reference = @reference
  taxon.protonym.authorship.save!
end
