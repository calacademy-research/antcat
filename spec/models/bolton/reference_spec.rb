# coding: UTF-8
require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new :authors => 'Allred, D.M.', :title => "Ants of Utah", :year => 1982
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah."
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory :bolton_reference, :citation_year => '1910a'
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory :bolton_reference, :citation_year => '1910a ["1958"]'
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe 'implementing ReferenceComparable' do
    it 'should map all fields correctly' do
      @bolton = Bolton::Reference.create! :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae',
        :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      @bolton.author.should == 'Fisher'
      @bolton.year.should == 1981
      @bolton.title.should == 'Dolichoderinae'
      @bolton.type.should == 'ArticleReference'
      @bolton.series_volume_issue.should == '1(2)'
      @bolton.pagination.should == '22-54'
    end
  end

  describe 'Searching' do

    it 'should simply return all records if there are no search terms' do
      reference = Factory :bolton_reference, :original => 'foo'
      Bolton::Reference.reindex
      Bolton::Reference.do_search.should == [reference]
    end

    it 'should find one term' do
      reference = Factory :bolton_reference, :original => 'foo'
      Bolton::Reference.reindex
      Bolton::Reference.do_search(:q => 'foo').should == [reference]
    end

    it 'should find not find one term' do
      reference = Factory :bolton_reference, :original => 'foo'
      Bolton::Reference.reindex
      Bolton::Reference.do_search(:q => 'bar').should be_empty
    end

    it 'should handle leading/trailing space' do
      reference = Factory :bolton_reference, :original => 'foo'
      Bolton::Reference.reindex
      Bolton::Reference.do_search(:q => ' foo ').should == [reference]
    end

    it 'should handle multiple terms' do
      reference = Factory :bolton_reference, :original => 'Bolton 1970'
      Bolton::Reference.reindex
      Bolton::Reference.do_search(:q => '1970 Bolton').should == [reference]
      Bolton::Reference.do_search(:q => 'Bolton').should == [reference]
      Bolton::Reference.do_search(:q => '1970').should == [reference]
      Bolton::Reference.do_search(:q => 'Fisher 1970').should be_empty
    end

    describe "Searching with a match threshold" do
      it "should find just the references whose best match is <= a threshold" do
        high_similarity = Factory :bolton_match, :similarity => 0.8
        low_similarity = Factory :bolton_match, :similarity => 0.7
        Bolton::Reference.do_search(:match_threshold => '.7').should == [low_similarity.bolton_reference]
      end
    end

  end

  describe "Matching" do
    it "should have a match, references, and a match_type" do
      reference = Factory :bolton_reference
      reference.match.should be_nil
      reference.possible_matches.should be_empty
      reference.match_type.should be_nil
      reference.match = Factory :book_reference
    end
  end

  describe "Setting the match" do
    it "should not set the match if there aren't any" do
      bolton = Factory :bolton_reference
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_type.should be_nil
    end
    it "should clear the match if there aren't any" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_type => 'automatic'
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_type.should be_nil
    end
    it "should set the match if there is one" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.set_match
      bolton.match.should == reference
      bolton.match_type.should == 'automatic'
    end
    it "should clear the match if there are more than one" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_type => 'automatic'
      2.times do |_|
        Factory :bolton_match, :bolton_reference => bolton, :reference => Factory(:book_reference)
      end
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_type.should be_nil
    end
  end
end
