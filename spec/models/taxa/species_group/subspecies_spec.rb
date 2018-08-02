require 'spec_helper'

describe Subspecies do
  let(:genus) { create_genus 'Atta' }

  it { is_expected.to validate_presence_of :genus }

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
    let!(:subspecies) { create_subspecies 'Atta beta kappa' }
    let!(:species) { create_species }

    it "sets all the parent fields" do
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
end
