require 'spec_helper'

describe Taxa::ElevateToSpecies do
  describe "#call" do
    let(:genus) { create_genus 'Atta' }

    it "turns the record into a Species" do
      taxon = create :subspecies
      expect(taxon).to be_kind_of Subspecies

      described_class[taxon]

      taxon = Species.find taxon.id
      expect(taxon).to be_kind_of Species
    end

    it "forms the new species name from the epithet" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create :subspecies, name: subspecies_name, genus: genus, species: species

      described_class[taxon]

      taxon = Species.find taxon.id
      expect(taxon.name.name).to eq 'Atta colobopsis'
      expect(taxon.name.epithet).to eq 'colobopsis'
      expect(taxon.name.epithets).to be_nil
    end

    it "creates a new species name, if necessary" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create :subspecies, name: subspecies_name, genus: genus, species: species
      name_count = Name.count

      described_class[taxon]

      expect(Name.count).to eq(name_count + 1)
    end

    it "reuses existing species name, if possible" do
      species = create_species 'Atta colobopsis', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create :subspecies, name: subspecies_name, genus: genus, species: species

      described_class[taxon]

      taxon = Species.find taxon.id
      expect(taxon.name).to eq species.name
    end

    it "doesn't crash and burn if the species already exists" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta batta major',
        epithet: 'major', epithets: 'batta major'
      taxon = create :subspecies, name: subspecies_name, species: species

      expect { described_class[taxon] }.not_to raise_error
    end
  end
end
