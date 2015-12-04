# coding: UTF-8
require 'spec_helper'

describe MissingReference do

  describe "Replacing" do

    describe "Replacing one missing reference" do
      before do
        @found_reference = FactoryGirl.create :article_reference
        @missing_reference = FactoryGirl.create :missing_reference
      end
      it "should replace references in taxt to the MissingReference to the found reference" do
        item = TaxonHistoryItem.create! taxt: "{ref #{@missing_reference.id}}"
        @missing_reference.replace_with @found_reference
        expect(item.reload.taxt).to eq("{ref #{@found_reference.id}}")
      end
      it "should not save records that don't contain the {ref}" do
        item = TaxonHistoryItem.create! taxt: "Just some taxt"
        item.reload
        updated_at = item.updated_at
        @missing_reference.replace_with @found_reference
        item.reload
        expect(item.updated_at).to eq(updated_at)
      end
      it "should replace references in citations" do
        citation = Citation.create! reference: @missing_reference
        @missing_reference.replace_with @found_reference
        expect(citation.reload.reference).to eq(@found_reference)
      end
    end

    describe "Replacing all occurences of a citation with another reference" do
      it "should replace both missing references with the same citation" do
        first_reference = FactoryGirl.create :missing_reference, citation: 'Citation'
        second_reference = FactoryGirl.create :missing_reference, citation: 'Citation'
        first_citation_occurrence = TaxonHistoryItem.create! taxt: "{ref #{first_reference.id}}"
        second_citation_occurrence = TaxonHistoryItem.create! taxt: "{ref #{second_reference.id}}"
        nonmissing_reference = FactoryGirl.create :article_reference

        MissingReference.replace_citation 'Citation', nonmissing_reference

        expect(first_citation_occurrence.reload.taxt).to eq("{ref #{nonmissing_reference.id}}")
        expect(second_citation_occurrence.reload.taxt).to eq("{ref #{nonmissing_reference.id}}")
      end
    end

  end

  describe "Optional year" do
    it "should permit a missing year (unlike other references)" do
      expect(MissingReference.new(title: 'missing', citation: 'Bolton')).to be_valid
    end
  end

  describe "Importing" do
    it "should create the reference based on the passed data" do
      reference = MissingReference.import 'no Bolton', :author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920: 22'
      expect(reference.reload.year).to eq(1920)
      expect(reference.citation).to eq('Bolton, 1920')
      expect(reference.reason_missing).to eq('no Bolton')
    end
    it "should save the whole thing in the citation if there's no colon" do
      reference = MissingReference.import 'no Bolton', :author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920'
      expect(reference.reload.year).to eq(1920)
      expect(reference.citation).to eq('Bolton, 1920')
      expect(reference.reason_missing).to eq('no Bolton')
    end
    it "should handle missing year" do
      reference = MissingReference.import 'no year', :author_names => ['Bolton'], :matched_text => 'Bolton'
      expect(reference.reload.year).to be_nil
      expect(reference.citation).to eq('Bolton')
      expect(reference.reason_missing).to eq('no year')
    end
  end

  describe "Key" do
    it "has its own kind of key" do
      reference = FactoryGirl.create :missing_reference
      expect(reference.key).to be_kind_of MissingReferenceKey
    end
  end

end
