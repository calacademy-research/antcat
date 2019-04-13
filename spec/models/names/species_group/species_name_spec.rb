require 'spec_helper'

describe SpeciesName do
  describe 'epithet validation' do
    subject { build_stubbed :species_name, name: 'Lasius niger' }

    it { is_expected.to allow_value('niger').for :epithet }
    it { is_expected.not_to allow_value('different').for :epithet }
  end

  describe "name parts" do
    let(:species_name) { described_class.new name: 'Atta major', epithet: 'major' }

    specify do
      expect(species_name.genus_epithet).to eq 'Atta'
      expect(species_name.species_epithet).to eq 'major'
    end
  end

  describe "#change_parent" do
    it "replaces the genus part of the name" do
      species_name = described_class.new name: 'Atta major', epithet: 'major'
      genus_name = GenusName.new name: 'Eciton', epithet: 'niger'
      species_name.change_parent genus_name

      expect(species_name.name).to eq 'Eciton major'
      expect(species_name.epithet).to eq 'major'
    end

    context "when name already exists" do
      context "when name is used by a different taxon" do
        let!(:species_name) { described_class.create! name: 'Atta major', epithet: 'major' }
        let!(:genus_name) { GenusName.create! name: 'Eciton', epithet: 'Eciton' }

        before do
          existing_species_name = described_class.create! name: 'Eciton major', epithet: 'major'
          create :species, name: existing_species_name

          GenusName.create! name: 'Eciton', epithet: 'Eciton' # protonym_name
        end

        it "raises" do
          expect { species_name.change_parent genus_name }.to raise_error Taxon::TaxonExists
        end
      end

      context "when name is an orphan" do
        let!(:species_name) { described_class.create! name: 'Atta minor', epithet: 'minor' }
        let!(:genus_name) { GenusName.create! name: 'Eciton', epithet: 'Eciton' }

        before do
          described_class.create! name: 'Eciton minor', epithet: 'minor' # orphan_species_name
          GenusName.create! name: 'Eciton', epithet: 'Eciton' # protonym_name
        end

        it "doesn't raise" do
          expect { species_name.change_parent genus_name }.not_to raise_error
        end
      end
    end
  end
end
