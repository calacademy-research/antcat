require 'spec_helper'

describe Hol::ReferenceMatcher do
  describe "getting the contents for an author" do
    before do
      @matcher = Hol::ReferenceMatcher.new
      @reference = Factory :reference
    end

    it "should get the contents for an author initially" do
      @matcher.should_receive(:read_references).and_return []
      @matcher.candidates_for @reference
    end
    it "should cache an author's contents" do
      @matcher.should_receive(:read_references).once().and_return []
      @matcher.candidates_for @reference
      @matcher.candidates_for @reference
    end
    it "should get a different author's contents" do
      bolton_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Bolton')]
      fisher_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Fisher')]
      @matcher.should_receive(:read_references).with(bolton_reference).once().and_return []
      @matcher.should_receive(:read_references).with(fisher_reference).once().and_return []
      @matcher.candidates_for bolton_reference
      @matcher.candidates_for fisher_reference
    end
  end

  describe "matching against Ward" do
    before do
      @matcher = Hol::ReferenceMatcher.new
    end

    it "should match an article reference based on year + series/volume/issue + pagination" do
      reference = Factory :article_reference, :citation_year => '2010', :series_volume_issue => '2', :pagination => '2-3'
      hol_references = [
        {:document_url => 'a source', :year => 2010, :series_volume_issue => '1', :pagination => '2-3'},
        {:document_url => 'another source', :year => 2010, :series_volume_issue => '2', :pagination => '2-3'},
      ]
      @matcher.stub!(:candidates_for).and_return hol_references
      @matcher.match(reference)[:document_url].should == 'another source'
    end

    it "should match an article reference based on year + title if series/volume/issue isn't found" do
      reference = Factory :article_reference, :citation_year => '2010', :series_volume_issue => '44', :pagination => '325-335',
        :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants'
      hol_references = [
        {:document_url => 'fernandez_source', :year => 2010, :series_volume_issue => '44(3)', :pagination => '325-335',
          :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants'},
      ]
      @matcher.stub!(:candidates_for).and_return hol_references
      @matcher.match(reference)[:document_url].should == 'fernandez_source'
    end

    it "ignore punctuation when comparing titles" do
      reference = Factory :article_reference, :citation_year => '2010', :series_volume_issue => '44', :pagination => '325-335',
        :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants (Hymenoptera, Formicidae)'
      hol_references = [
        {:document_url => 'fernandez_source', :year => 2010, :series_volume_issue => '44(3)', :pagination => '325-335',
          :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants (Hymenoptera: Formicidae)'},
      ]
      @matcher.stub!(:candidates_for).and_return hol_references
      @matcher.match(reference)[:document_url].should == 'fernandez_source'
    end

    it "should report as much when a failed match was because the author had no entries" do
      reference = Factory :reference
      @matcher.stub!(:candidates_for).and_return []
      result = @matcher.match reference
      result[:document_url].should be_nil
    end

  end

end
