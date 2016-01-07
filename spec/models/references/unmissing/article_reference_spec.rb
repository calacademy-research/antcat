require 'spec_helper'

describe ArticleReference do

  describe "parsing fields from series_volume_issue" do
    it "can parse out volume and issue" do
      reference = FactoryGirl.create(:article_reference, :series_volume_issue => "92(32)")
      expect(reference.volume).to eq('92')
      expect(reference.issue).to eq('32')
    end

    it "can parse out the series and volume" do
      reference = FactoryGirl.create(:article_reference, :series_volume_issue => '(10)8')
      expect(reference.series).to eq('10')
      expect(reference.volume).to eq('8')
    end

    it "can parse out series, volume and issue" do
      reference = FactoryGirl.create(:article_reference, :series_volume_issue => '(I)C(xix):129-131.')
      expect(reference.series).to eq('I')
      expect(reference.volume).to eq('C')
      expect(reference.issue).to eq('xix')
    end
  end

  describe "parsing fields from pagination" do

    it "should parse beginning and ending page numbers" do
      reference = FactoryGirl.create(:article_reference, :pagination => '163-181')
      expect(reference.start_page).to eq('163')
      expect(reference.end_page).to eq('181')
    end

    it "should parse just a single page number" do
      reference = FactoryGirl.create(:article_reference, :pagination => "8")
      expect(reference.start_page).to eq('8')
      expect(reference.end_page).to be_nil
    end

  end

  describe "validation" do
    before do
      author_name = FactoryGirl.create :author_name
      journal = FactoryGirl.create :journal
      @reference = ArticleReference.new :author_names => [author_name], :title => 'Title', :citation_year => '2010a',
        :journal => journal, :series_volume_issue => '1', :pagination => '2'
    end

    it "should be valid the way I just set it up" do
      expect(@reference).to be_valid
    end
    it "should not be valid without a series/volume/issue" do
      @reference.series_volume_issue = nil
      expect(@reference).not_to be_valid
    end
    it "should not be valid without a journal" do
      @reference.journal = nil
      expect(@reference).not_to be_valid
    end
  end

end
