require 'spec_helper'

describe Taxa::CallbacksAndValidations do
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

  describe "#homonym_replaced_by" do
    context 'when taxon is not a homonym' do
      let(:taxon) { build_stubbed :family }
      let(:replaced_by) { build_stubbed :family }

      specify do
        expect { taxon.homonym_replaced_by = replaced_by }.to change { taxon.valid? }.to false
        expect(taxon.errors.messages).to include(homonym_replaced_by: ["can't be set for non-homonyms"])
      end
    end
  end

  describe "#unresolved_homonym" do
    context 'when taxon is a homonym' do
      let(:taxon) { build_stubbed :family, unresolved_homonym: true }

      specify do
        expect { taxon.status = Status::HOMONYM }.to change { taxon.valid? }.to false
        expect(taxon.errors.messages).to include(unresolved_homonym: ["can't be set for homonyms"])
      end
    end
  end

  describe "#nomen_nudum" do
    context 'when taxon is not unavailable' do
      let(:taxon) { build_stubbed :family }

      specify do
        expect { taxon.nomen_nudum = true }.to change { taxon.valid? }.to(false)
        expect(taxon.errors.messages).to include(nomen_nudum: ["can only be set for unavailable taxa"])
      end
    end

    context 'when taxon is unavailable' do
      let(:taxon) { build_stubbed :family, :unavailable }

      specify do
        expect { taxon.nomen_nudum = true }.to_not change { taxon.valid? }.from(true)
      end
    end
  end

  describe "#current_valid_taxon_validation" do
    context "when taxon has a `#current_valid_taxon`" do
      [
        Status::VALID,
        Status::UNIDENTIFIABLE,
        Status::UNAVAILABLE,
        Status::EXCLUDED_FROM_FORMICIDAE,
        Status::HOMONYM
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :family, status: status, current_valid_taxon: create(:family) }

          specify do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_valid_name: ["can't be set for #{Status.plural(status)} taxa"])
          end
        end
      end
    end

    context "when taxon has no `#current_valid_taxon`" do
      [
        Status::SYNONYM,
        Status::ORIGINAL_COMBINATION,
        Status::OBSOLETE_COMBINATION,
        Status::UNAVAILABLE_MISSPELLING,
        Status::UNAVAILABLE_UNCATEGORIZED
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :family, status: status }

          specify do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_valid_name: ["must be set for #{Status.plural(status)}"])
          end
        end
      end
    end
  end

  describe "#ensure_correct_name_type" do
    context 'when `Taxon` and `Name` classes do not match' do
      context 'when taxon is created' do
        let(:genus_name) { create :genus_name }
        let(:family) { build_stubbed :family, name: genus_name }

        specify do
          expect(family.valid?).to eq false
          expect(family.errors.messages[:base].first).to include 'and name type (`GenusName`) must match'
        end
      end

      context 'when taxon is updated' do
        let(:family) { create :family }
        let(:genus_name) { create :genus_name }

        specify do
          expect { family.name = genus_name }.to change { family.valid? }.from(true).to(false)
          expect(family.errors.messages[:base].first).to include 'and name type (`GenusName`) must match'
        end
      end
    end
  end
end
