require 'spec_helper'

describe Subspecies do
  it { should validate_presence_of :genus }

  let(:genus) { create_genus 'Atta' }

  describe "#statistics" do
    it "has no statistics" do
      expect(described_class.new.statistics).to be_nil
    end
  end

  it "does not have to have a species (before being fixed up, e.g.)" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: genus, species: nil
    expect(subspecies).to be_valid
  end

  it "has its subfamily assigned from its genus" do
    subspecies = create_subspecies 'Atta major colobopsis', species: nil, genus: genus
    expect(subspecies.subfamily).to eq genus.subfamily
  end

  it "has its genus assigned from its species, if there is one" do
    species = create_species genus: genus
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: species
    subspecies.save # Trigger callbacks. TODO fix factories.

    expect(subspecies.genus).to eq genus
  end

  it "does not have its genus assigned from its species, if there is not one" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: genus, species: nil
    expect(subspecies.genus).to eq genus
  end

  describe "#update_parent" do
    it "sets all the parent fields" do
      subspecies = create_subspecies 'Atta beta kappa'
      species = create_species

      subspecies.update_parent species
      expect(subspecies.species).to eq species
      expect(subspecies.genus).to eq species.genus
      expect(subspecies.subgenus).to eq species.subgenus
      expect(subspecies.subfamily).to eq species.subfamily
    end
  end

  describe "#parent" do
    context "without a species" do
      let(:taxon) { create_subspecies genus: genus, species: nil }

      it "returns the genus" do
        expect(taxon.parent).to eq genus
      end
    end
  end

  describe "#elevate_to_species" do
    it "turns the record into a Species" do
      taxon = create_subspecies 'Atta major colobopsis'
      expect(taxon).to be_kind_of Subspecies

      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon).to be_kind_of Species
    end

    it "forms the new species name from the epithet" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create_subspecies name: subspecies_name, genus: genus, species: species

      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon.name.name).to eq 'Atta colobopsis'
      expect(taxon.name.epithet).to eq 'colobopsis'
      expect(taxon.name.epithets).to be_nil
    end

    it "creates a new species name, if necessary" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create_subspecies name: subspecies_name, genus: genus, species: species
      name_count = Name.count

      taxon.elevate_to_species
      expect(Name.count).to eq(name_count + 1)
    end

    it "reuses existing species name, if possible" do
      species = create_species 'Atta colobopsis', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
        epithet: 'colobopsis', epithets: 'major colobopsis'
      taxon = create_subspecies name: subspecies_name, genus: genus, species: species

      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon.name).to eq species.name
    end

    it "doesn't crash and burn if the species already exists" do
      species = create_species 'Atta major', genus: genus
      subspecies_name = SubspeciesName.create! name: 'Atta batta major',
        epithet: 'major', epithets: 'batta major'
      taxon = create_subspecies name: subspecies_name, species: species

      expect { taxon.elevate_to_species }.not_to raise_error
    end
  end
end
