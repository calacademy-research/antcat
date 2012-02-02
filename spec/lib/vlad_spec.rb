# coding: UTF-8
require 'spec_helper'

describe Vlad do
  it "should idate" do
    Vlad.idate
  end

  it "should show genera with tribes but not subfamilies" do
    tribe = Factory :tribe
    genus_with_tribe_but_not_subfamily = Factory :genus, subfamily: nil, tribe: tribe
    genus_with_tribe_and_subfamily = Factory :genus, subfamily: tribe.subfamily, tribe: tribe
    genus_with_subfamily_but_not_tribe = Factory :genus, subfamily: tribe.subfamily, tribe: nil
    results = Vlad.idate[:genera_with_tribes_but_not_subfamilies]
    results.count.should == 1
    results.first.should == genus_with_tribe_but_not_subfamily
  end

  it "should show taxa whose status doesn't match their synonym_of" do
    tribe = Factory :tribe
    no_synonym = Factory :genus, status: 'synonym'
    no_status = Factory :tribe, synonym_of: tribe
    ok = Factory :species, synonym_of: Factory(:species), status: 'synonym'

    results = Vlad.idate[:taxa_with_mismatched_synonym_and_status]
    results.map(&:id).should =~ [no_synonym.id, no_status.id]
  end

  describe "Duplicate checking" do

    it "should show duplicate names" do
      Factory :genus, :name => 'Eciton'
      Factory :genus, :name => 'Atta'
      Factory :genus, :name => 'Atta'
      Vlad.idate[:duplicates].map {|e| [e.name, e.count]}.should =~ [['Atta', 2]]
    end
    it "should be cool with same species name if genus is different" do
      Factory :species, :name => 'niger'
      Factory :species, :name => 'major'
      Factory :species, :name => 'major'
      Vlad.idate[:duplicates].should be_empty
    end
  end

  describe "Reference document locations" do
    it "should summarize where reference documents are" do
      stub_request(:any, /.*/)

      1.times {Factory :reference_document, url: 'http://antcat.org/documents/5242/Keller_2011_Bull_Am_Mus_Nat_Hist Evolution of ant morphology.pdf', reference: Factory(:article_reference)}

      2.times {Factory :reference_document, url: 'http://antbase.org/ants/publications/11008/11008.pdf', reference: Factory(:article_reference)}
      3.times {Factory :reference_document, url: 'http://128.146.250.117/pdfs/4885/4885.pdf', reference: Factory(:article_reference)}
      4.times {Factory :reference_document, reference: Factory(:article_reference)}

      reference_without_document = Factory :article_reference
      document_without_reference = Factory :reference_document

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
