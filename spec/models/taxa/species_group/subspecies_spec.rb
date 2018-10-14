require 'spec_helper'

describe Subspecies do
  let(:genus) { create :genus }

  it { is_expected.to validate_presence_of :genus }

  describe "#statistics" do
    it "has no statistics" do
      expect(described_class.new.statistics).to be_nil
    end
  end

  it "does not have to have a species (before being fixed up, e.g.)" do
    subspecies = create :subspecies, genus: genus, species: nil
    expect(subspecies).to be_valid
  end

  it "has its subfamily assigned from its genus" do
    subspecies = create :subspecies, species: nil, genus: genus
    expect(subspecies.subfamily).to eq genus.subfamily
  end

  it "has its genus assigned from its species, if there is one" do
    species = create :species, genus: genus
    subspecies = create :subspecies, genus: nil, species: species
    subspecies.save # Trigger callbacks. TODO fix factories.

    expect(subspecies.genus).to eq genus
  end

  it "does not have its genus assigned from its species, if there is not one" do
    subspecies = create :subspecies, genus: genus, species: nil
    expect(subspecies.genus).to eq genus
  end

  describe "#update_parent" do
    let(:subspecies) { create :subspecies }
    let(:new_parent) { create :species }

    it "sets all the parent fields" do
      subspecies.update_parent new_parent

      expect(subspecies.species).to eq new_parent
      expect(subspecies.genus).to eq new_parent.genus
      expect(subspecies.subgenus).to eq new_parent.subgenus
      expect(subspecies.subfamily).to eq new_parent.subfamily
    end

    describe "updating the name" do
      let(:subspecies) do
        create :subspecies, name: create(:subspecies_name, name: 'Atta major medius minor')
      end
      let(:new_parent) { create_species 'Eciton nigrus' }

      specify do
        subspecies.update_parent new_parent

        expect(subspecies.name.name).to eq 'Eciton nigrus medius minor'
        expect(subspecies.name.name_html).to eq '<i>Eciton nigrus medius minor</i>'
        expect(subspecies.name.epithet).to eq 'minor'
        expect(subspecies.name.epithet_html).to eq '<i>minor</i>'
        expect(subspecies.name.epithets).to eq 'nigrus medius minor'
      end
    end
  end

  describe "#parent" do
    context "without a species" do
      let(:taxon) { create :subspecies, genus: genus, species: nil }

      specify { expect(taxon.parent).to eq genus }
    end
  end
end
