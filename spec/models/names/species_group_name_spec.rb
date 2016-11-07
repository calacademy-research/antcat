require 'spec_helper'

describe SpeciesGroupName do
  let(:name) { SpeciesName.new name: 'Atta major', epithet: 'major' }

  describe "#genus_epithet" do
    it "knows its genus epithet" do
      expect(name.genus_epithet).to eq 'Atta'
    end
  end

  describe "#species_epithet" do
    it "knows its species epithet" do
      expect(name.species_epithet).to eq 'major'
    end
  end

  describe ".name_for_new_comb" do
    let(:genus) { create_genus "Atta" }
    let(:species) { create_species "Lasius cactusia" }
    let(:subspecies) { create_subspecies "Formica luigi peligrosa" }

    context "when `new_comb_parent` is a species" do
      let(:new_comb_parent) { species }
      let(:old_comb) { subspecies }

      it "returns a correctly formatted `SubspeciesName`" do
        new_comb_name = SpeciesGroupName.name_for_new_comb old_comb, new_comb_parent

        expect(new_comb_name).to be_a SubspeciesName
        expect(new_comb_name.name).to eq "Lasius cactusia peligrosa"
      end
    end

    context "when `new_comb_parent` is a genus" do
      let(:new_comb_parent) { genus }
      let(:old_comb) { species }

      it "returns a correctly formatted `SpeciesName`" do
        new_comb_name = SpeciesGroupName.name_for_new_comb old_comb, new_comb_parent

        expect(new_comb_name).to be_a SpeciesName
        expect(new_comb_name.name).to eq "Atta cactusia"
      end
    end

    it "raises on invalid rank combinations" do
      species = create_species
      uncombinable_parent = create_subfamily

      expect do
        SpeciesGroupName.name_for_new_comb species, uncombinable_parent
      end.to raise_error /uncombinable/
    end
  end
end
