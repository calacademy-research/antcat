require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleReference do

  describe "importing" do

    it "should create the reference and set its data" do
      reference = ArticleReference.import({}, {:series_volume_issue => '12', :pagination => '32-33', :journal => 'Ecology Letters'})
      reference.series_volume_issue.should == '12'
      reference.pagination.should == '32-33'
      reference.journal.title.should == 'Ecology Letters'
    end

  end

  describe "parsing fields from series_volume_issue" do
    it "can parse out volume and issue" do
      reference = Factory(:article_reference, :series_volume_issue => "92(32)")
      reference.volume.should == '92'
      reference.issue.should == '32'
    end

    it "can parse out the series and volume" do
      reference = Factory(:article_reference, :series_volume_issue => '(10)8')
      reference.series.should == '10'
      reference.volume.should == '8'
    end

    it "can parse out series, volume and issue" do
      reference = Factory(:article_reference, :series_volume_issue => '(I)C(xix):129-131.')
      reference.series.should == 'I'
      reference.volume.should == 'C'
      reference.issue.should == 'xix'
    end
  end

  describe "parsing fields from pagination" do
    it "should parse beginning and ending page numbers" do
      reference = Factory(:article_reference, :pagination => '163-181')
      reference.start_page.should == '163'
      reference.end_page.should == '181'
    end

    it "should parse just a single page number" do
      reference = Factory(:article_reference, :pagination => "8")
      reference.start_page.should == '8'
      reference.end_page.should be_nil
    end
  end

  describe "citation" do
    it "should format a citation" do
      journal = Journal.create! :title => 'Ants'
      reference = ArticleReference.new :journal => journal, :series_volume_issue => '(2)1(2)', :pagination => '34-46'
      reference.citation.should == 'Ants (2)1(2):34-46.'
    end
  end

end
