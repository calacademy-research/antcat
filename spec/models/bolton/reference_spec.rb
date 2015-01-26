# coding: UTF-8
require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new :authors => 'Allred, D.M.', :title => "Ants of Utah", :citation_year => '1982'
      expect(bolton.to_s).to eq("Allred, D.M. 1982. Ants of Utah.")
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = FactoryGirl.create :bolton_reference, :citation_year => '1910a'
      expect(reference.year).to eq(1910)
      reference.citation_year = '2010b'
      reference.save!
      expect(reference.year).to eq(2010)
    end

    it "should set the year to the stated year, if present" do
      reference = FactoryGirl.create :bolton_reference, :citation_year => '1910a ["1958"]'
      expect(reference.year).to eq(1958)
      reference.citation_year = '2010b'
      reference.save!
      expect(reference.year).to eq(2010)
    end
  end

  describe 'implementing ReferenceComparable' do
    it 'should map all fields correctly' do
      @bolton = Bolton::Reference.create! :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae',
        :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      expect(@bolton.author).to eq('Fisher')
      expect(@bolton.year).to eq(1981)
      expect(@bolton.title).to eq('Dolichoderinae')
      expect(@bolton.type).to eq('ArticleReference')
      expect(@bolton.series_volume_issue).to eq('1(2)')
      expect(@bolton.pagination).to eq('22-54')
    end
  end

  describe 'Searching' do
    include EnableSunspot

    it 'should simply return all records if there are no search terms' do
      reference = FactoryGirl.create :bolton_reference, :original => 'foo'
      expect(Bolton::Reference.do_search).to eq([reference])
    end

    it 'should find one term' do
      reference = FactoryGirl.create :bolton_reference, :original => 'foo'
      expect(Bolton::Reference.do_search(:q => 'foo')).to eq([reference])
    end

    it 'should find not find one term' do
      reference = FactoryGirl.create :bolton_reference, :original => 'foo'
      expect(Bolton::Reference.do_search(:q => 'bar')).to be_empty
    end

    it 'should handle leading/trailing space' do
      reference = FactoryGirl.create :bolton_reference, :original => 'foo'
      expect(Bolton::Reference.do_search(:q => ' foo ')).to eq([reference])
    end

    it 'should handle multiple terms' do
      reference = FactoryGirl.create :bolton_reference, :original => 'Bolton 1970'
      expect(Bolton::Reference.do_search(:q => '1970 Bolton')).to eq([reference])
      expect(Bolton::Reference.do_search(:q => 'Bolton')).to eq([reference])
      expect(Bolton::Reference.do_search(:q => '1970')).to eq([reference])
      expect(Bolton::Reference.do_search(:q => 'Fisher 1970')).to be_empty
    end

    describe "Searching with a match threshold" do
      it "should find just the references whose best match is <= a threshold" do
        high_similarity = FactoryGirl.create :bolton_match, :similarity => 0.8
        low_similarity = FactoryGirl.create :bolton_match, :similarity => 0.7
        expect(Bolton::Reference.do_search(:match_threshold => '.7')).to eq([low_similarity.bolton_reference])
      end
    end

    describe "Searching by match type" do
      it "should find the ones that aren't matched" do
        bolton = FactoryGirl.create :bolton_reference
        expect(Bolton::Reference.do_search(:match_statuses => [nil])).to eq([bolton])
      end
      it "should find the ones that have been matched automatically" do
        auto_match = FactoryGirl.create :bolton_reference, :match_status => 'auto'
        not_matched = FactoryGirl.create :bolton_reference, :match_status => nil
        expect(Bolton::Reference.do_search(:match_statuses => [nil])).to eq([not_matched])
        expect(Bolton::Reference.do_search(:match_statuses => [nil, 'auto']).map(&:id)).to match_array([not_matched.id, auto_match.id])
        expect(Bolton::Reference.do_search(:match_statuses => ['auto']).map(&:id)).to match_array([auto_match.id])
      end
      it "should find the ones that have been matched manually" do
        manual_match = FactoryGirl.create :bolton_reference, :match_status => 'manual'
        not_matched = FactoryGirl.create :bolton_reference, :match_status => nil
        expect(Bolton::Reference.do_search(:match_statuses => ['manual']).map(&:id)).to match_array([manual_match.id])
      end
      it "should find the ones that have been marked unmatchable" do
        unmatchable = FactoryGirl.create :bolton_reference, :match_status => 'unmatchable'
        not_matched = FactoryGirl.create :bolton_reference, :match_status => nil
        expect(Bolton::Reference.do_search(:match_statuses => ['unmatchable']).map(&:id)).to match_array([unmatchable.id])
      end
    end

  end

  describe "Matching" do
    it "should have a match, references, and a match_status" do
      reference = FactoryGirl.create :bolton_reference
      expect(reference.match).to be_nil
      expect(reference.possible_matches).to be_empty
      expect(reference.match_status).to be_nil
      reference.match = FactoryGirl.create :book_reference
    end
  end

  describe "Setting the match" do
    it "should not set the match if there aren't any" do
      bolton = FactoryGirl.create :bolton_reference
      bolton.set_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should clear the match if there aren't any" do
      bolton = FactoryGirl.create :bolton_reference, :match => FactoryGirl.create(:book_reference), :match_status => 'auto'
      bolton.set_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should set the match manually" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      bolton.set_match_manually reference.id
      expect(bolton.match).to eq(reference)
      expect(bolton.match_status).to eq('manual')
    end
    it "should set the references to unmatchable" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      bolton.set_match_manually 'unmatchable'
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to eq('unmatchable')
    end
    it "should reset the match if the passed match is nil" do
      bolton = FactoryGirl.create :bolton_reference, :match => FactoryGirl.create(:book_reference), :match_status => 'auto'
      reference = FactoryGirl.create :book_reference
      bolton.set_match_manually reference.id
      bolton.set_match_manually nil
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should clear the match completely, not revert to auto" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.set_match
      expect(bolton.match).to eq(reference)
      expect(bolton.match_status).to eq('auto')
      bolton.set_match_manually nil
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should set the match if there is one" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.set_match
      expect(bolton.match).to eq(reference)
      expect(bolton.match_status).to eq('auto')
    end
    it "should not set the match if the similarity is too low" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.7
      bolton.set_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should reset the match if the similarity is too low" do
      bolton = FactoryGirl.create :bolton_reference, :match => FactoryGirl.create(:book_reference), :match_status => 'auto'
      reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.7
      bolton.set_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
    it "should clear the match if there are more than one" do
      bolton = FactoryGirl.create :bolton_reference, :match => FactoryGirl.create(:book_reference), :match_status => 'auto'
      2.times do |_|
        FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => FactoryGirl.create(:book_reference)
      end
      bolton.set_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to be_nil
    end
  end

  describe "Updating matches" do
    it "should set an unmatched reference normally" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference
      bolton.update_match
      expect(bolton.match).to eq(reference)
      expect(bolton.match_status).to eq('auto')
    end
    it "should leave the reference alone if it was set manually" do
      manually_set_reference = FactoryGirl.create :reference
      another_reference = FactoryGirl.create :reference
      bolton = FactoryGirl.create :bolton_reference, :match => manually_set_reference, :match_status => 'manual'
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => another_reference
      bolton.update_match
      expect(bolton.match).to eq(manually_set_reference)
      expect(bolton.match_status).to eq('manual')
    end
    it "should leave the reference alone if it was set as unmatcheable" do
      another_reference = FactoryGirl.create :reference
      bolton = FactoryGirl.create :bolton_reference, :match_status => 'unmatchable'
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => another_reference
      bolton.update_match
      expect(bolton.match).to be_nil
      expect(bolton.match_status).to eq('unmatchable')
    end
    it "should change the match if it was auto" do
      auto_set_reference = FactoryGirl.create :reference
      another_reference = FactoryGirl.create :reference
      bolton = FactoryGirl.create :bolton_reference, :match => auto_set_reference, :match_status => 'auto'
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => another_reference
      bolton.update_match
      expect(bolton.match).to eq(another_reference)
      expect(bolton.match_status).to eq('auto')
    end
  end

  describe "Best match similarity" do
    it "should return nil if there are none" do
      expect(FactoryGirl.create(:bolton_reference).best_match_similarity).to be_nil
    end
    it "should return the similarity of all its matches" do
      bolton = FactoryGirl.create :bolton_reference
      reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => reference, :similarity => 0.1
      expect(bolton.best_match_similarity).to eq(0.1)
    end
  end

  describe "Matches with matched first" do
    it "return the matches, with the matched one first" do
      bolton = FactoryGirl.create :bolton_reference
      first_match_reference = FactoryGirl.create :book_reference
      second_match_reference = FactoryGirl.create :book_reference
      matched_reference = FactoryGirl.create :book_reference
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => first_match_reference, :similarity => 0.1
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => second_match_reference, :similarity => 0.1
      FactoryGirl.create :bolton_match, :bolton_reference => bolton, :reference => matched_reference, :similarity => 0.1
      bolton.update_attribute :match, matched_reference
      possible_matches = bolton.possible_matches_with_matched_first
      expect(possible_matches.first).to eq(matched_reference)
      expect(possible_matches.map(&:id)).to match_array([matched_reference.id, first_match_reference.id, second_match_reference.id])
    end
    it "return the match even if it's not a Bolton::Match" do
      bolton = FactoryGirl.create :bolton_reference
      matched_reference = FactoryGirl.create :book_reference

      bolton.update_attribute :match, matched_reference
      possible_matches = bolton.possible_matches_with_matched_first
      expect(possible_matches.first).to eq(matched_reference)
      expect(possible_matches.map(&:id)).to match_array([matched_reference.id])
    end
  end

  describe "Match status counts" do
    it "should work" do
      2.times {|i| FactoryGirl.create :bolton_reference, :match_status => nil}
      3.times {|i| FactoryGirl.create :bolton_reference, :match_status => 'auto'}
      4.times {|i| FactoryGirl.create :bolton_reference, :match_status => 'manual'}
      5.times {|i| FactoryGirl.create :bolton_reference, :match_status => 'unmatchable'}
      expect(Bolton::Reference.match_status_auto_count).to eq(3)
      expect(Bolton::Reference.match_status_manual_count).to eq(4)
      expect(Bolton::Reference.match_status_none_count).to eq(2)
      expect(Bolton::Reference.match_status_unmatchable_count).to eq(5)
    end
  end

  describe 'Key' do
    it "should create a key when saved" do
      bolton = Bolton::Reference.create! :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae',
        :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      expect(bolton.reload.key_cache).to eq('Fisher 1981')
    end
  end

  describe "Key" do
    it "has a key" do
      reference = FactoryGirl.create :bolton_reference
      reference.key
    end
  end

  describe "Import" do
    it "should create a reference if none exists" do
      reference = Bolton::Reference.import :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      expect(reference.reload.import_result).to eq('added')
    end
    it "should mark existing record as identical to imported record" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes
      expect(reference.reload.import_result).to be_nil

      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('identical')
    end
    it "should update an existing record if the authors, year and title are the same" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54', :original => 'Dolichoderinae 1(2)'}
      reference = Bolton::Reference.create! attributes

      attributes[:series_volume_issue] = '2(3)'
      attributes[:original] = 'Dolichoderinae 2(3)'
      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('updated')
      expect(reference.series_volume_issue).to eq('2(3)')
    end
    it "should update an existing record if the authors and year are the same, but should log the title change" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:title] = 'Atta'
      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('updated_title')
      expect(reference.title).to eq('Atta')
    end
    it "should update an existing record if the authors and title are the same, but should log the year change" do
      attributes = {authors: 'Fisher, B. L.', citation_year: '1981', title: 'Dolichoderinae', reference_type: 'ArticleReference', series_volume_issue: '1(2)', pagination: '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:citation_year] = '1981a'
      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('updated_year')
      expect(reference.year).to eq(1981)
      expect(reference.citation_year).to eq('1981a')
    end
    it "should update an existing record if the authors and title are the same, but should log the year change" do
      attributes = {
        authors: 'Xu, Z. & Liu, X.',
        citation_year: '2011',
        title: 'Three new species of the ant genus Myopias from China, with a key to the known Chinese species',
        reference_type: 'ArticleReference',
        journal: 'Sociobiology',
        series_volume_issue: '58',
        pagination: ' 819-834 [not seen]'
      }
      existing_reference = Bolton::Reference.create! attributes

      attributes = {
        authors: 'Xu, Z. & Liu, X.',
        citation_year: '2012',
        title: 'Three new species of the ant genus Myopias from China, with a key to the known Chinese species',
        reference_type: 'UnknownReference',
        journal: nil,
        series_volume_issue: nil,
        pagination: ' 819-834 [not seen]'
      }

      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('updated_year')
      expect(reference.year).to eq(2012)
      expect(reference.citation_year).to eq('2012')
    end

    it "should update an existing record if the title and year are the same, but should log the author change" do
      attributes = {:authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae', :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'}
      reference = Bolton::Reference.create! attributes

      attributes[:authors] = 'Fisher, Martha'
      reference = Bolton::Reference.import attributes
      expect(reference.reload.import_result).to eq('updated_authors')
      expect(reference.authors).to eq('Fisher, Martha')
    end
  end

end
