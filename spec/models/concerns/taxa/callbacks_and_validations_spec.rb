require 'spec_helper'

describe Taxa::CallbacksAndValidations do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    it 'only includes database scripts with `issue_description`s' do
      Taxa::CheckIfInDatabaseResults::DATABASE_SCRIPTS_TO_CHECK.map(&:new).each do |database_script|
        expect(database_script.issue_description.present?).to eq true
      end

      # Sanity check.
      expect(DatabaseScripts::ValidSpeciesList.new.issue_description).to eq nil
    end
  end

  describe '#check_if_in_database_scripts_results' do
    context 'when taxon is a species in a fossil genus' do
      let(:taxon) { create :species, genus: create(:genus, :fossil) }

      it 'is `valid?` but has soft-validation warnings' do
        expect(taxon.valid?).to be true
        expect(taxon.has_soft_validation_warnings?).to be true
      end

      it 'adds a warning' do
        taxon.has_soft_validation_warnings?
        expect(taxon.soft_validation_warnings[:base].first[:message]).
          to eq "The parent of this taxon is fossil, but this taxon is extant."
      end
    end
  end

  describe "#set_taxon_state_to_waiting" do
    context "when creating a taxon" do
      let(:taxon) { build :family }

      it "creates a taxon_state" do
        expect(taxon.taxon_state).to be nil
        taxon.save
        expect(taxon.taxon_state).not_to be nil
      end

      it "sets the review_status to 'waiting'" do
        taxon.save
        expect(taxon.reload.waiting?).to eq true
      end
    end

    context "when updating" do
      let(:taxon) { create :family, :old }

      context "when it `save_initiator`" do
        it "sets the review_status to 'waiting'" do
          taxon.save_initiator = true
          expect { taxon.save }.to change { taxon.reload.waiting? }.to true
        end

        it "doesn't cascade" do
          family = create :family, :old
          subfamily = create :subfamily, :old, family: family

          expect(family.reload.waiting?).to be false
          expect(subfamily.reload.waiting?).to be false

          family.save_initiator = true
          family.save

          expect(family.reload.waiting?).to be true
          expect(subfamily.reload.waiting?).to be false
        end
      end

      context "when it not `save_initiator`" do
        it "doesn't change the review state" do
          expect { taxon.save }.to_not change { taxon.old? }
        end
      end
    end
  end

  describe "#remove_auto_generated" do
    context "when a generated taxon" do
      it "removes 'auto_generated' flags from things" do
        # Setup.
        taxon = create :family, auto_generated: true

        # Act and test.
        taxon.save_initiator = true
        taxon.save

        expect(taxon.reload).not_to be_auto_generated
      end

      it "doesn't cascade" do
        # Setup.
        family = create :family, auto_generated: true
        subfamily = create :subfamily, family: family, auto_generated: true

        # Act and test.
        family.save_initiator = true
        family.save

        expect(family.reload).not_to be_auto_generated
        expect(subfamily.reload).to be_auto_generated
      end
    end
  end

  describe "#biogeographic_region" do
    context 'when taxon is a `SpeciesGroupTaxon`' do
      subject { build_stubbed :species }

      specify do
        expect(subject).to validate_inclusion_of(:biogeographic_region).
          in_array(Taxon::BIOGEOGRAPHIC_REGIONS).allow_nil
      end
    end

    context 'when taxon is above `SpeciesGroupTaxon`' do
      subject { build_stubbed :genus }

      it { is_expected.to validate_absence_of(:biogeographic_region) }
    end
  end

  describe "#current_valid_taxon_validation" do
    context "when taxon has a `#current_valid_taxon`" do
      let(:taxon) { build :family, status: status, current_valid_taxon: create(:family) }

      context 'when status is "valid"' do
        let(:status) { Status::VALID }

        specify do
          taxon.valid?
          expect(taxon.errors.messages).to include(current_valid_name: ["can't be set for valid taxa"])
        end
      end

      context 'when status is "unavailable"' do
        let(:status) { Status::UNAVAILABLE }

        specify do
          taxon.valid?
          expect(taxon.errors.messages).to include(current_valid_name: ["can't be set for unavailable taxa"])
        end
      end
    end

    context "when taxon has no `#current_valid_taxon`" do
      let(:taxon) { build :family, status: status }

      context 'when status is "synonym"' do
        let(:status) { Status::SYNONYM }

        specify do
          taxon.valid?
          expect(taxon.errors.messages).to include(current_valid_name: ["must be set for synonyms"])
        end
      end

      context 'when status is "original_combination"' do
        let(:status) { Status::ORIGINAL_COMBINATION }

        specify do
          taxon.valid?
          expect(taxon.errors.messages).to include(current_valid_name: ["must be set for original combinations"])
        end
      end

      context 'when status is "obsolete_combination"' do
        let(:status) { Status::OBSOLETE_COMBINATION }

        specify do
          taxon.valid?
          expect(taxon.errors.messages).to include(current_valid_name: ["must be set for obsolete combinations"])
        end
      end
    end
  end

  describe "#ensure_correct_name_type" do
    let(:family) { create :family }

    context 'when `Taxon` and `Name` classes do not match' do
      let(:genus_name) { create :genus_name }

      specify do
        expect { family.name = genus_name }.to change { family.valid? }.from(true).to(false)
        expect(family.errors.messages[:base].first).to include 'must match'
      end
    end
  end
end
