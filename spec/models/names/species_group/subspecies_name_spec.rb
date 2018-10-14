require 'spec_helper'

describe SubspeciesName do
  describe "name parts" do
    context 'when three name parts' do
      let(:subspecies_name) do
        described_class.new name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      end

      specify do
        expect(subspecies_name.genus_epithet).to eq 'Atta'
        expect(subspecies_name.species_epithet).to eq 'major'
        expect(subspecies_name.subspecies_epithets).to eq 'minor'
      end
    end

    context 'when four name parts' do
      let(:subspecies_name) do
        described_class.new name: 'Acus major minor medium', epithet: 'medium', epithets: 'major minor medium'
      end

      specify do
        expect(subspecies_name.subspecies_epithets).to eq 'minor medium'
      end
    end
  end

  # TODO DRY
  describe "#change_parent" do
    it "replaces the species part of the name and fix all the other parts, too" do
      subspecies_name = described_class.new name: 'Atta major minor',
        epithet: 'minor', epithets: 'major minor'
      species_name = SpeciesName.new name: 'Eciton niger', epithet: 'niger'

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq 'Eciton niger minor'
      expect(subspecies_name.epithet).to eq 'minor'
      expect(subspecies_name.epithets).to eq 'niger minor'
    end

    it "handles more than one subspecies epithet" do
      subspecies_name = described_class.new name: 'Atta major minor medii',
        epithet: 'medii', epithets: 'major minor medii'
      species_name = SpeciesName.new name: 'Eciton niger', epithet: 'niger'

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq 'Eciton niger minor medii'
      expect(subspecies_name.epithet).to eq 'medii'
      expect(subspecies_name.epithets).to eq 'niger minor medii'
    end

    context "when name already exists" do
      let!(:subspecies_name) { create(:subspecies_name, name: 'Atta major minor') }
      let!(:species_name) { create(:species_name, name: 'Eciton niger') }
      let!(:existing_subspecies_name) { create(:subspecies_name, name: 'Eciton niger minor') }

      context "when name is used by a different taxon" do
        before do
          create :subspecies, name: existing_subspecies_name
        end

        it "raises" do
          expect { subspecies_name.change_parent species_name }.to raise_error Taxon::TaxonExists
        end
      end

      context "when name is an orphan" do
        it "doesn't raise" do
          expect { subspecies_name.change_parent species_name }.not_to raise_error
        end
      end
    end
  end
end
