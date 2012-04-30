# coding: UTF-8
require 'spec_helper'

describe Vlad do
  it "should idate" do
    Vlad.idate
  end

  it "should show genera with tribes but not subfamilies" do
    tribe = FactoryGirl.create :tribe
    genus_with_tribe_but_not_subfamily = FactoryGirl.create :genus, subfamily: nil, tribe: tribe
    genus_with_tribe_and_subfamily = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: tribe
    genus_with_subfamily_but_not_tribe = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: nil
    results = Vlad.idate[:genera_with_tribes_but_not_subfamilies]
    results.count.should == 1
    results.first.should == genus_with_tribe_but_not_subfamily
  end

  it "should show taxa whose status doesn't match their synonym_of" do
    tribe = FactoryGirl.create :tribe
    no_synonym = FactoryGirl.create :genus, status: 'synonym'
    no_status = FactoryGirl.create :tribe, synonym_of: tribe
    ok = FactoryGirl.create :species, synonym_of: FactoryGirl.create(:species), status: 'synonym'

    results = Vlad.idate[:taxa_with_mismatched_synonym_and_status]
    results.map(&:id).should =~ [no_synonym.id, no_status.id]
  end

  describe "Duplicate checking" do

    it "should show duplicate names" do
      FactoryGirl.create :genus, :name => 'Eciton'
      FactoryGirl.create :genus, :name => 'Atta'
      FactoryGirl.create :genus, :name => 'Atta'
      Vlad.idate[:duplicates].map {|e| [e.name, e.count]}.should =~ [['Atta', 2]]
    end
    it "should be cool with same species name if genus is different" do
      FactoryGirl.create :species, :name => 'niger'
      FactoryGirl.create :species, :name => 'major'
      FactoryGirl.create :species, :name => 'major'
      Vlad.idate[:duplicates].should be_empty
    end
  end

  describe "Reference document locations" do
    it "should summarize where reference documents are" do
      stub_request(:any, /.*/)

      1.times {FactoryGirl.create :reference_document, url: 'http://antcat.org/documents/5242/Keller_2011_Bull_Am_Mus_Nat_Hist Evolution of ant morphology.pdf', reference: FactoryGirl.create(:article_reference)}

      2.times {FactoryGirl.create :reference_document, url: 'http://antbase.org/ants/publications/11008/11008.pdf', reference: FactoryGirl.create(:article_reference)}
      3.times {FactoryGirl.create :reference_document, url: 'http://128.146.250.117/pdfs/4885/4885.pdf', reference: FactoryGirl.create(:article_reference)}
      4.times {FactoryGirl.create :reference_document, reference: FactoryGirl.create(:article_reference)}

      reference_without_document = FactoryGirl.create :article_reference
      document_without_reference = FactoryGirl.create :reference_document

      results = Vlad.reference_documents[:reference_documents]
      results[:references_count].should == 11
      results[:reference_documents_count].should == 11
      results[:references_with_documents_count].should == 10

      results[:locations][:antcat].should == 1
      results[:locations][:antbase].should == 2
      results[:locations][:ip_128_146_250_117].should == 3
      results[:locations][:other].should == 4

    end
  end

end
