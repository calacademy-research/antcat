# coding: UTF-8
require 'spec_helper'

describe Vlad do
  it "should idate" do
    Vlad.idate
  end

  it "should show taxon counts by rank" do
    FactoryGirl.create :family
    expect(Vlad::TaxonCounts.query).to match_array([['Family', 1]])
  end

  it "should show taxon counts by status" do
    FactoryGirl.create :family, status: 'synonym', name: create_name('Family1')
    FactoryGirl.create :family, status: 'valid', name: create_name('Family2')
    FactoryGirl.create :family, status: 'valid', name: create_name('Family3')
    expect(Vlad::StatusCounts.query).to match_array([['valid', 2], ['synonym', 1]])
  end

  it "should show genera with tribes but not subfamilies" do
    tribe = FactoryGirl.create :tribe
    genus_with_tribe_but_not_subfamily = FactoryGirl.create :genus, subfamily: nil, tribe: tribe
    genus_with_tribe_and_subfamily = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: tribe
    genus_with_subfamily_but_not_tribe = FactoryGirl.create :genus, subfamily: tribe.subfamily, tribe: nil
    results = Vlad::GeneraWithTribesButNotSubfamilies.query
    expect(results.count).to eq(1)
    expect(results.first).to eq(genus_with_tribe_but_not_subfamily)
  end

  it "should show names without taxa or type names" do
    eciton = create_name 'Eciton'
    formica = create_name 'Formica'
    atta = create_name 'Atta'
    create_subfamily type_name: eciton
    create_subfamily type_name: nil, protonym: FactoryGirl.create(:protonym, name: formica)
    results = Vlad::NamesWithoutTaxa.query
    expect(results.count).to eq(1)
    expect(results.first.to_s).to eq('Atta')
  end

  it "should show subspecies without species" do
    species = create_species
    subspecies_with_species = create_subspecies 'Atta major minor', species: species
    subspecies_without_species = create_subspecies 'Atta major minor', species: nil
    results = Vlad::SubspeciesWithoutSpecies.query
    expect(results.count).to eq(1)
    expect(results.first).to eq(subspecies_without_species)
  end

  it "should show taxa with synonym status, but no synonyms" do
    genus = create_genus
    no_synonym = create_genus status: 'synonym'
    has_synonym = create_synonym genus
    results = Vlad::SynonymsWithoutSeniors.query
    expect(results.map(&:id)).to match_array([no_synonym.id])
  end

  it "should show synonym cycles" do
    genus = create_genus 'Atta'
    another_genus = create_genus 'Betta'
    synonym_a = Synonym.create! senior_synonym: genus, junior_synonym: another_genus
    expect(another_genus).to be_synonym_of genus
    expect(Vlad::SynonymCycles.query).to be_blank

    synonym_b = Synonym.create! senior_synonym: another_genus, junior_synonym: genus
    expect(genus).to be_synonym_of another_genus
    results = Vlad::SynonymCycles.query
    expect(Vlad::SynonymCycles.query).not_to be_blank
    expect(results.size).to eq(1)
    expect(results).to eq([['Atta', 'Betta']])
  end

  it "should show protonyms without authorships" do
    protonym_with_authorship = FactoryGirl.create :protonym
    protonym_without_authorship = FactoryGirl.create :protonym
    protonym_without_authorship.update_attribute :authorship, nil

    protonym_without_authorship_or_taxon = FactoryGirl.create :protonym
    protonym_without_authorship_or_taxon.update_attribute :authorship, nil

    expect(protonym_without_authorship.reload.authorship).to be_nil

    create_genus protonym: protonym_with_authorship
    genus = create_genus
    genus.update_attribute :protonym, protonym_without_authorship

    results = Vlad::ProtonymsWithoutAuthorships.query
    expect(results).to match_array([protonym_without_authorship, protonym_without_authorship_or_taxon])

    expect {Vlad::ProtonymsWithoutAuthorships.display}.not_to raise_error
  end

  it "should show taxa without protonyms" do
    genus = create_genus
    genus_without_protonym = create_genus
    genus_without_protonym.update_attribute :protonym, nil
    results = Vlad::TaxaWithoutProtonyms.query
    expect(results).to eq([genus_without_protonym])
    expect {Vlad::TaxaWithoutProtonyms.display}.not_to raise_error
  end

  it "should show taxa with deleted protonyms" do
    taxon = create_genus
    taxon.protonym.destroy
    results = Vlad::TaxaWithDeletedProtonyms.query
    expect(results).to eq([taxon])
    expect {Vlad::TaxaWithDeletedProtonyms.display}.not_to raise_error
  end

  it "should show orphan protonyms" do
    genus = create_genus
    orphan_protonym = FactoryGirl.create :protonym
    expect {Vlad::OrphanProtonyms.display}.not_to raise_error
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
    expect(results.map(&:junior_synonym_id)).to match_array([junior.id])
  end


  describe "Duplicate checking" do
    it "should show duplicate valid names" do
      create_genus 'Eciton'
      genus = create_genus 'Atta'
      create_genus name: genus.name
      expect(Vlad::DuplicateValids.query.map {|e| [e[:name], e[:count]]}).to match_array([['Atta', 2]])
    end
    it "should be cool with same species name if genus is different" do
      create_species 'Atta niger'
      create_species 'Betta major'
      create_species 'Kappa major'
      expect(Vlad::DuplicateValids.query).to be_empty
    end
    it "should be cool with same species name if status is different" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      create_species name: species.name, genus: genus, status: 'synonym'
      expect(Vlad::DuplicateValids.query).to be_empty
    end
    it "should be cool with same name if both statuses are valid, but one is an unresolved junior homonym" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      create_species name: species.name, genus: genus, unresolved_homonym: true
      expect(Vlad::DuplicateValids.query).to be_empty
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
      expect(results[:references_count]).to eq(11)
      expect(results[:reference_documents_count]).to eq(11)
      expect(results[:references_with_documents_count]).to eq(10)

      expect(results[:locations][:antcat]).to eq(1)
      expect(results[:locations][:antbase]).to eq(2)
      expect(results[:locations][:ip_128_146_250_117]).to eq(3)
      expect(results[:locations][:other]).to eq(4)

    end
  end

  describe "Finding synonyms without current valid taxon" do
    it "should return just the synonyms and just those w/o current valid taxon" do
      taxon = create_species
      senior_synonym = create_species
      junior_synonym = create_synonym senior_synonym
      another_senior_synonym = create_species
      another_junior_synonym = create_synonym another_senior_synonym, current_valid_taxon: taxon
      results = Vlad::SynonymsWithoutCurrentValidTaxon.query
      expect(results.size).to eq(1)
      expect(results.first).to eq(junior_synonym)
    end
  end

end
