require 'spec_helper'

describe SpeciesName do
  describe '#name=' do
    specify do
      name = described_class.new(name: 'Lasius niger')

      expect(name.name).to eq 'Lasius niger'
      expect(name.epithet).to eq 'niger'
      expect(name.epithets).to eq nil
    end

    specify do
      name = described_class.new(name: 'Lasius (Austrolasius) niger')

      expect(name.name).to eq 'Lasius (Austrolasius) niger'
      expect(name.epithet).to eq 'niger'
      expect(name.epithets).to eq '(Austrolasius) niger'
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
      species_name.change_parent genus_name

      expect(species_name.name).to eq 'Eciton major'
      expect(species_name.epithet).to eq 'major'
    end

    context "when name already exists" do
      context "when name is used by a different taxon" do
        let!(:species_name) { described_class.create!(name: 'Atta major') }
        let!(:genus_name) { GenusName.create!(name: 'Eciton') }

        before do
          existing_species_name = described_class.create!(name: 'Eciton major')
          create :species, name: existing_species_name

          GenusName.create!(name: 'Eciton') # protonym_name
        end

        it "raises" do
          expect { species_name.change_parent genus_name }.to raise_error Taxon::TaxonExists
        end
      end

      context "when name is an orphan" do
        let!(:species_name) { described_class.create! name: 'Atta minor' }
        let!(:genus_name) { GenusName.create! name: 'Eciton' }

        before do
          described_class.create!(name: 'Eciton minor') # orphan_species_name
          GenusName.create!(name: 'Eciton') # protonym_name
        end

        it "doesn't raise" do
          expect { species_name.change_parent genus_name }.not_to raise_error
        end
      end
    end
  end
end
