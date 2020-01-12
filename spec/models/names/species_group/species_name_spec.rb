require 'rails_helper'

describe SpeciesName do
  describe '#name=' do
    specify do
      name = described_class.new(name: 'Lasius niger')

      expect(name.name).to eq 'Lasius niger'
      expect(name.epithet).to eq 'niger'
    end

    specify do
      name = described_class.new(name: 'Lasius (Austrolasius) niger')

      expect(name.name).to eq 'Lasius (Austrolasius) niger'
      expect(name.epithet).to eq 'niger'
    end
  end

  describe "name parts" do
    let(:species_name) { described_class.new(name: 'Atta major') }

    specify do
      expect(species_name.genus_epithet).to eq 'Atta'
      expect(species_name.species_epithet).to eq 'major'
    end
  end

  describe "#change_parent" do
    it "replaces the genus part of the name" do
      species_name = described_class.new(name: 'Atta major')
      genus_name = GenusName.new(name: 'Eciton')

      expect { species_name.change_parent genus_name }.to change { species_name.name }.to('Eciton major')
    end

    context "when name already exists" do
      let!(:species_name) { described_class.create!(name: 'Atta major') }
      let!(:genus_name) { GenusName.create!(name: 'Eciton') }
      let!(:existing_name) { described_class.create!(name: 'Eciton major') }

      context "when name is an orphan" do
        it "doesn't raise" do
          expect { species_name.change_parent genus_name }.not_to raise_error
        end
      end

      context "when name is used by a different taxon" do
        before do
          create :species, name: existing_name
        end

        it "raises" do
          expect { species_name.change_parent genus_name }.to raise_error Taxa::TaxonExists
        end
      end
    end
  end
end
