require 'spec_helper'

describe Species do
  before do
    @reference = create :article_reference
  end

  it "can have subspecies, which are its children" do
    species = create_species 'Atta chilensis'
    create_subspecies 'Atta chilensis robusta', species: species
    create_subspecies 'Atta chilensis saltensis', species: species
    species = Species.find_by_name 'Atta chilensis'

    subspecies_epithets = species.subspecies.map(&:name).map(&:epithet)
    expect(subspecies_epithets).to match_array ['robusta', 'saltensis']
    expect(species.children).to eq species.subspecies
  end

  describe "#statistics" do
    it "handles 0 children" do
      expect(create_species.statistics).to eq({})
    end

    it "handles 1 valid subspecies" do
      species = create_species
      create_subspecies species: species

      expect(species.statistics).to eq(
        extant: {
          subspecies: { 'valid' => 1 }
        }
      )
    end

    it "differentiates between extant and fossil subspecies" do
      species = create_species
      create_subspecies species: species
      create_subspecies species: species, fossil: true

      expect(species.statistics).to eq(
        extant: {
          subspecies: { 'valid' => 1 }
        },
        fossil: {
          subspecies: { 'valid' => 1 }
        }
      )
    end

    it "differentiates between extant and fossil subspecies" do
      species = create_species
      create_subspecies species: species
      create_subspecies species: species, fossil: true

      expect(species.statistics).to eq(
        extant: {
          subspecies: { 'valid' => 1 }
        },
        fossil: {
          subspecies: { 'valid' => 1 }
        }
      )
    end

    it "handles 1 valid subspecies and 2 synonyms" do
      species = create_species
      create_subspecies species: species
      2.times { create_subspecies species: species, status: 'synonym' }

      expect(species.statistics).to eq(
        extant: {
          subspecies: { 'valid' => 1, 'synonym' => 2 }
        }
      )
    end
  end

  describe "#become_subspecies_of" do
    let(:genus) { create_genus 'Atta' }

    it "turns the record into a Subspecies" do
      taxon = create_species 'Atta minor', genus: genus
      taxon.protonym.name.name = 'Atta (Myrma) minor'
      taxon.protonym.name.save!
      new_species = create_species 'Atta major', genus: genus

      taxon.become_subspecies_of new_species
      taxon = Subspecies.find taxon.id
      expect(taxon.name.name).to eq 'Atta major minor'
      expect(taxon.name.epithets).to eq 'major minor'
      expect(taxon).to be_kind_of Subspecies
      expect(taxon.name).to be_kind_of SubspeciesName
      expect(taxon.name_cache).to eq 'Atta major minor'
    end

    it "sets the species, genus and subfamily" do
      taxon = create_species 'Atta minor', genus: genus
      new_species = create_species 'Atta major', genus: genus

      taxon.become_subspecies_of new_species
      taxon = Subspecies.find taxon.id
      expect(taxon.species).to eq new_species
      expect(taxon.genus).to eq new_species.genus
      expect(taxon.subfamily).to eq new_species.subfamily
    end

    it "should handle when the new subspecies exists" do
      taxon = create_species 'Camponotus dallatorrei', genus: genus
      new_species = create_species 'Camponotus alii', genus: genus
      existing_subspecies = create_subspecies 'Atta alii dallatorrei', genus: genus

      expect { taxon.become_subspecies_of new_species }.to raise_error Taxon::TaxonExists
    end

    it "should handle when the new subspecies name exists, but just as the protonym of the new subspecies" do
      subspecies_name = create :subspecies_name, name: 'Atta major minor'
      taxon = create_species 'Atta minor', genus: genus, protonym: create(:protonym, name: subspecies_name)
      new_species = create_species 'Atta major', genus: genus

      taxon.become_subspecies_of new_species
      taxon = Subspecies.find taxon.id
      expect(taxon.name.name).to eq 'Atta major minor'
    end
  end

  describe "#siblings" do
    it "returns itself and its genus's species" do
      create_species
      genus = create_genus
      species = create_species genus: genus
      another_species = create_species genus: genus

      expect(species.siblings).to match_array [species, another_species]
    end
  end
end
