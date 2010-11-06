require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleCitationGrammar do

  it "should recognize and parse a simple citation" do
    ArticleCitationGrammar.parse('Title 1:1').value.should ==
      {:journal_title_series_volume_issue => 'Title 1', :pagination => '1'}
  end

  it "should fail when the colon isn't immediately followed by pagination" do
    lambda {ArticleCitationGrammar.parse('New York: Wiley, 3 pp.')}.should
      raise_error Citrus::ParseError
  end

end
