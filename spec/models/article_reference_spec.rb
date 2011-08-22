# coding: UTF-8
require 'spec_helper'

describe ArticleReference do

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

  describe "validation" do
    before do
      author_name = Factory :author_name
      journal = Factory :journal
      @reference = ArticleReference.new :author_names => [author_name], :title => 'Title', :citation_year => '2010a',
        :journal => journal, :series_volume_issue => '1', :pagination => '2'
    end

    it "should be valid the way I just set it up" do
      @reference.should be_valid
    end
    it "should not be valid without a series/volume/issue" do
      @reference.series_volume_issue = nil
      @reference.should_not be_valid
    end
    it "should not be valid without a journal" do
      @reference.journal = nil
      @reference.should_not be_valid
    end
  end

end
