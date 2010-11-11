require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleCitationGrammar do

  it "should recognize and parse a simple citation" do
    ArticleCitationGrammar.parse('Name 1:1').value.should ==
      {:journal_name_series_volume_issue => 'Name 1', :pagination => '1'}
  end

  it "should recognize and parse a citation with more than one word" do
    ArticleCitationGrammar.parse('Journal of Ants 1:1').value.should ==
      {:journal_name_series_volume_issue => 'Journal of Ants 1', :pagination => '1'}
  end

  it "should fail when the colon isn't immediately followed by pagination" do
    lambda {ArticleCitationGrammar.parse('New York: Wiley, 3 pp.')}.should raise_error Citrus::ParseError
  end
  
  it "should fail when it doesn't start with a capital letter" do
    lambda {ArticleCitationGrammar.parse('name 1:1')}.should raise_error Citrus::ParseError
  end

  it "should not fail when it starts with a UTF-8 capital letter" do
    ArticleCitationGrammar.parse('Öfversigt 1:1').value.should ==
      {:journal_name_series_volume_issue => 'Öfversigt 1', :pagination => '1'}
  end

end
