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
        item.reload.taxt.should == "{ref #{@found_reference.id}}"
      end
      it "should not save records that don't contain the {ref}" do
        item = TaxonHistoryItem.create! taxt: "Just some taxt"
        item.reload
        updated_at = item.updated_at
        @missing_reference.replace_with @found_reference
        item.reload
        item.updated_at.should == updated_at
      end
      it "should replace references in citations" do
        citation = Citation.create! reference: @missing_reference
        @missing_reference.replace_with @found_reference
        citation.reload.reference.should == @found_reference
      end
    end

    describe "Replacing all missing references" do
      it "should replace all missing references" do
        missing_reference = FactoryGirl.create :missing_reference, citation: 'Borowiec, 2010'
        protonym = FactoryGirl.create :protonym, authorship: FactoryGirl.create(:citation, reference: missing_reference)
        taxon = create_genus protonym: protonym
        taxon.protonym.authorship.reference.should == missing_reference
        nonmissing_reference = FactoryGirl.create :article_reference, key_cache_no_commas: 'Borowiec 2010'

        MissingReference.replace_all

        MissingReference.count.should == 0
        taxon.reload.protonym.authorship.reference.should == nonmissing_reference
      end
      it "should report the MissingReferences that can't be found" do
        missing_reference = FactoryGirl.create :missing_reference, citation: 'Borowiec, 2010'
        MissingReference.replace_all.should == ['Borowiec, 2010']
        MissingReference.count.should == 1
      end
    end

  end

  describe "Optional year" do
    it "should permit a missing year (unlike other references)" do
      MissingReference.new(title: 'missing', citation: 'Bolton').should be_valid
    end
  end

  describe "Importing" do
    it "should create the reference based on the passed data" do
      reference = MissingReference.import 'no Bolton', :author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920: 22'
      reference.reload.year.should == 1920
      reference.citation.should == 'Bolton, 1920'
      reference.reason_missing.should == 'no Bolton'
    end
    it "should save the whole thing in the citation if there's no colon" do
      reference = MissingReference.import 'no Bolton', :author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920'
      reference.reload.year.should == 1920
      reference.citation.should == 'Bolton, 1920'
      reference.reason_missing.should == 'no Bolton'
    end
    it "should handle missing year" do
      reference = MissingReference.import 'no year', :author_names => ['Bolton'], :matched_text => 'Bolton'
      reference.reload.year.should be_nil
      reference.citation.should == 'Bolton'
      reference.reason_missing.should == 'no year'
    end
  end

  describe "Key" do
    it "has its own kind of key" do
      reference = FactoryGirl.create :missing_reference
      reference.key.should be_kind_of MissingReferenceKey
    end
  end

end
