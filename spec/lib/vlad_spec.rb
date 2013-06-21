# coding: UTF-8
require 'spec_helper'

describe Vlad do
  it "should idate" do
    Vlad.idate
  end

  it "should show taxon counts by rank" do
    FactoryGirl.create :family
    Vlad::TaxonCounts.query.should =~ [['Family', 1]]
  end

  it "should show taxon counts by status" do
    FactoryGirl.create :family, status: 'synonym', name: create_name('Family1')
    FactoryGirl.create :family, status: 'valid', name: create_name('Family2')
    FactoryGirl.create :family, status: 'valid', name: create_name('Family3')
    Vlad::StatusCounts.query.should =~ [['valid', 2], ['synonym', 1]]
  end

  it "should show genera with tribes but not subfamilies" do
    tribe = FactoryGirl.create :tribe
    genus_with_tribe_but_not_subfamily = FactoryGirl.create :genus, subfamily: nil, tribe: tribe
    genus_with_tribe_and_subfamily = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: tribe
    genus_with_subfamily_but_not_tribe = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: nil
    results = Vlad::GeneraWithTribesButNotSubfamilies.query
    results.count.should == 1
    results.first.should == genus_with_tribe_but_not_subfamily
  end

  it "should show names without taxa or type names" do
    eciton = create_name 'Eciton'
    formica = create_name 'Formica'
    atta = create_name 'Atta'
    create_subfamily type_name: eciton
    create_subfamily type_name: nil, protonym: FactoryGirl.create(:protonym, name: formica)
    results = Vlad::NamesWithoutTaxa.query
    results.count.should == 1
    results.first.to_s.should == 'Atta'
  end

  it "should show subspecies without species" do
    species = create_species
    subspecies_with_species = create_subspecies 'Atta major minor', species: species
    subspecies_without_species = create_subspecies 'Atta major minor', species: nil
    results = Vlad::SubspeciesWithoutSpecies.query
    results.count.should == 1
    results.first.should == subspecies_without_species
  end

  it "should show taxa with synonym status, but no synonyms" do
    genus = create_genus
    no_synonym = create_genus status: 'synonym'
    has_synonym = create_synonym genus
    results = Vlad::SynonymsWithoutSeniors.query
    results.map(&:id).should =~ [no_synonym.id]
  end

  it "should show synonym cycles" do
    genus = create_genus 'Atta'
    another_genus = create_genus 'Betta'
    synonym_a = Synonym.create! senior_synonym: genus, junior_synonym: another_genus
    another_genus.should be_synonym_of genus
    Vlad::SynonymCycles.query.should be_blank

    synonym_b = Synonym.create! senior_synonym: another_genus, junior_synonym: genus
    genus.should be_synonym_of another_genus
    results = Vlad::SynonymCycles.query
    Vlad::SynonymCycles.query.should_not be_blank
    results.should have(1).item
    results.should == [['Atta', 'Betta']]
  end

  it "should show protonyms without authorships" do
    protonym_with_authorship = FactoryGirl.create :protonym
    protonym_without_authorship = FactoryGirl.create :protonym
    protonym_without_authorship.update_attribute :authorship, nil

    protonym_without_authorship_or_taxon = FactoryGirl.create :protonym
    protonym_without_authorship_or_taxon.update_attribute :authorship, nil

    protonym_without_authorship.reload.authorship.should be_nil

    create_genus protonym: protonym_with_authorship
    create_genus protonym: protonym_without_authorship

    results = Vlad::ProtonymsWithoutAuthorships.query
    results.should =~ [protonym_without_authorship, protonym_without_authorship_or_taxon]

    -> {Vlad::ProtonymsWithoutAuthorships.display}.should_not raise_error
  end

  it "should show duplicate synonyms" do
    senior = create_genus
    junior = create_genus
    synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
    Synonym.create! senior_synonym: senior, junior_synonym: junior
    another_senior = create_genus
    another_junior = create_genus
    Synonym.create! senior_synonym: another_senior, junior_synonym: another_junior
    results = Vlad::DuplicateSynonyms.query
    results.map(&:junior_synonym_id).should =~ [junior.id]
  end

  describe "Duplicate checking" do
    it "should show duplicate valid names" do
      create_genus 'Eciton'
      genus = create_genus 'Atta'
      create_genus name: genus.name
      Vlad::DuplicateValids.query.map {|e| [e[:name], e[:count]]}.should =~ [['Atta', 2]]
    end
    it "should be cool with same species name if genus is different" do
      create_species 'Atta niger'
      create_species 'Betta major'
      create_species 'Kappa major'
      Vlad::DuplicateValids.query.should be_empty
    end
    it "should be cool with same species name if status is different" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      create_species name: species.name, genus: genus, status: 'synonym'
      Vlad::DuplicateValids.query.should be_empty
    end
    it "should be cool with same name if both statuses are valid, but one is an unresolved junior homonym" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      create_species name: species.name, genus: genus, unresolved_homonym: true
      Vlad::DuplicateValids.query.should be_empty
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

      results = Vlad::ReferenceDocumentCounts.query
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
