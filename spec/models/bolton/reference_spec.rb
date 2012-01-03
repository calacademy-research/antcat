# coding: UTF-8
require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new :authors => 'Allred, D.M.', :title => "Ants of Utah", :citation_year => '1982'
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

    describe "Searching by match type" do
      it "should find the ones that aren't matched" do
        bolton = Factory :bolton_reference
        Bolton::Reference.do_search(:match_statuses => [nil]).should == [bolton]
      end
      it "should find the ones that have been matched automatically" do
        auto_match = Factory :bolton_reference, :match_status => 'auto'
        not_matched = Factory :bolton_reference, :match_status => nil
        Bolton::Reference.do_search(:match_statuses => [nil]).should == [not_matched]
        Bolton::Reference.do_search(:match_statuses => [nil, 'auto']).map(&:id).should =~ [not_matched.id, auto_match.id]
        Bolton::Reference.do_search(:match_statuses => ['auto']).map(&:id).should =~ [auto_match.id]
      end
      it "should find the ones that have been matched manually" do
        manual_match = Factory :bolton_reference, :match_status => 'manual'
        not_matched = Factory :bolton_reference, :match_status => nil
        Bolton::Reference.do_search(:match_statuses => ['manual']).map(&:id).should =~ [manual_match.id]
      end
      it "should find the ones that have been marked unmatchable" do
        unmatchable = Factory :bolton_reference, :match_status => 'unmatchable'
        not_matched = Factory :bolton_reference, :match_status => nil
        Bolton::Reference.do_search(:match_statuses => ['unmatchable']).map(&:id).should =~ [unmatchable.id]
      end
    end

  end

  describe "Matching" do
    it "should have a match, references, and a match_status" do
      reference = Factory :bolton_reference
      reference.match.should be_nil
      reference.possible_matches.should be_empty
      reference.match_status.should be_nil
      reference.match = Factory :book_reference
    end
  end

  describe "Setting the match" do
    it "should not set the match if there aren't any" do
      bolton = Factory :bolton_reference
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should clear the match if there aren't any" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_status => 'auto'
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should set the match manually" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      bolton.set_match_manually reference.id
      bolton.match.should == reference
      bolton.match_status.should == 'manual'
    end
    it "should set the references to unmatchable" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      bolton.set_match_manually 'unmatchable'
      bolton.match.should be_nil
      bolton.match_status.should == 'unmatchable'
    end
    it "should reset the match if the passed match is nil" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_status => 'auto'
      reference = Factory :book_reference
      bolton.set_match_manually reference.id
      bolton.set_match_manually nil
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should clear the match completely, not revert to auto" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.set_match
      bolton.match.should == reference
      bolton.match_status.should == 'auto'
      bolton.set_match_manually nil
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should set the match if there is one" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.set_match
      bolton.match.should == reference
      bolton.match_status.should == 'auto'
    end
    it "should not set the match if the similarity is too low" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.7
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should reset the match if the similarity is too low" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_status => 'auto'
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.7
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
    it "should clear the match if there are more than one" do
      bolton = Factory :bolton_reference, :match => Factory(:book_reference), :match_status => 'auto'
      2.times do |_|
        Factory :bolton_match, :bolton_reference => bolton, :reference => Factory(:book_reference)
      end
      bolton.set_match
      bolton.match.should be_nil
      bolton.match_status.should be_nil
    end
  end

  describe "Best match similarity" do
    it "should return nil if there are none" do
      Factory(:bolton_reference).best_match_similarity.should be_nil
    end
    it "should return the similarity of all its matches" do
      bolton = Factory :bolton_reference
      reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.1
      bolton.best_match_similarity.should == 0.1
    end
  end

  describe "Matches with matched first" do
    it "return the matches, with the matched one first" do
      bolton = Factory :bolton_reference
      first_match_reference = Factory :book_reference
      second_match_reference = Factory :book_reference
      matched_reference = Factory :book_reference
      Factory :bolton_match, :bolton_reference => bolton, :reference => first_match_reference, :similarity => 0.1
      Factory :bolton_match, :bolton_reference => bolton, :reference => second_match_reference, :similarity => 0.1
      Factory :bolton_match, :bolton_reference => bolton, :reference => matched_reference, :similarity => 0.1
      bolton.update_attribute :match, matched_reference
      possible_matches = bolton.possible_matches_with_matched_first
      possible_matches.first.should == matched_reference
      possible_matches.map(&:id).should =~ [matched_reference.id, first_match_reference.id, second_match_reference.id]
    end
    it "return the match even if it's not a Bolton::Match" do
      bolton = Factory :bolton_reference
      matched_reference = Factory :book_reference

      bolton.update_attribute :match, matched_reference
      possible_matches = bolton.possible_matches_with_matched_first
      possible_matches.first.should == matched_reference
      possible_matches.map(&:id).should =~ [matched_reference.id]
    end
  end

  describe "Match status counts" do 
    it "should work" do
      2.times {|i| Factory :bolton_reference, :match_status => nil}
      3.times {|i| Factory :bolton_reference, :match_status => 'auto'}
      4.times {|i| Factory :bolton_reference, :match_status => 'manual'}
      5.times {|i| Factory :bolton_reference, :match_status => 'unmatchable'}
      Bolton::Reference.match_status_auto_count.should == 3
      Bolton::Reference.match_status_manual_count.should == 4
      Bolton::Reference.match_status_none_count.should == 2
      Bolton::Reference.match_status_unmatchable_count.should == 5
    end
  end

  describe 'Key' do
    it "should create a key when saved" do
      bolton = Bolton::Reference.create! :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae',
        :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      bolton.reload.key_cache.should == 'Fisher 1981'
    end
  end

  describe "Key" do
    it "has a key" do
      reference = Factory :bolton_reference
      reference.key
    end
  end

  describe "Import" do
    it "should create a reference if none exists" do
      reference = Bolton::Reference.import :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      reference.reload.import_result.should == 'added'
    end
    it "should mark existing record as identical to imported record" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes
      reference.reload.import_result.should be_nil

      reference = Bolton::Reference.import attributes
      reference.reload.import_result.should == 'identical'
    end
    it "should update an existing record if the authors, year and title are the same" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54', :original => 'Dolichoderinae 1(2)'}
      reference = Bolton::Reference.create! attributes

      attributes[:series_volume_issue] = '2(3)'
      attributes[:original] = 'Dolichoderinae 2(3)'
      reference = Bolton::Reference.import attributes
      reference.reload.import_result.should == 'updated'
      reference.series_volume_issue.should == '2(3)'
    end
    it "should update an existing record if the authors and year are the same, but should log the title change" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:title] = 'Atta'
      reference = Bolton::Reference.import attributes
      reference.reload.import_result.should == 'updated_title'
      reference.title.should == 'Atta'
    end
    it "should update an existing record if the authors and title are the same, but should log the year change" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:citation_year] = '1981a'
      reference = Bolton::Reference.import attributes
      reference.reload.import_result.should == 'updated_year'
      reference.year.should == 1981
      reference.citation_year.should == '1981a'
    end
    it "should update an existing record if the title and year are the same, but should log the author change" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:authors] = 'Fisher, Martha'
      reference = Bolton::Reference.import attributes
      reference.reload.import_result.should == 'updated_authors'
      reference.authors.should == 'Fisher, Martha'
    end
  end
end
