require 'spec_helper'

describe SubspeciesName do
  subject do
    described_class.new name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
  end

  describe "#name_parts" do
    it "knows its species epithet" do
      expect(subject.genus_epithet).to eq 'Atta'
      expect(subject.species_epithet).to eq 'major'
      expect(subject.subspecies_epithets).to eq 'minor'
    end
  end

  # TODO DRY
  # Changing the species of a subspecies name
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
      context "when name is used by a different taxon" do
        it "raises" do
          existing_subspecies_name = described_class.create! name: 'Eciton niger minor',
            epithet: 'minor', epithets: 'niger minor'
          create_subspecies 'Eciton niger minor', name: existing_subspecies_name

          subspecies_name = described_class.create! name: 'Atta major minor',
            epithet: 'minor', epithets: 'major minor'
          species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
          protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'

          expect { subspecies_name.change_parent species_name }.
            to raise_error Taxon::TaxonExists
        end
      end

      context "when name is an orphan" do
        it "doesn't raise" do
          orphan_subspecies_name = described_class.create! name: 'Eciton niger minor',
            epithet: 'minor', epithets: 'niger minor'
          subspecies_name = described_class.create! name: 'Atta major minor',
            epithet: 'minor', epithets: 'major minor'
          species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
          protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'

          expect { subspecies_name.change_parent species_name }.not_to raise_error
        end
      end
    end
  end

  describe "#subspecies_epithets" do
    subject do
      described_class.new name: 'Acus major minor medium',
        epithet: 'medium', epithets: 'major minor medium'
    end

    it "is the subspecies epithets minus the species epithet" do
      expect(subject.subspecies_epithets).to eq 'minor medium'
    end
  end
end
