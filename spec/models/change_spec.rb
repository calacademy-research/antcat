require 'spec_helper'

describe Change do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user).on(:create) }
  end

  describe "scopes" do
    describe ".waiting" do
      let!(:unreviewed_change) { create :change, taxon: create(:family, :waiting) }

      before do
        create :change, taxon: create(:family, :old)
      end

      it "returns unreviewed changes" do
        expect(described_class.waiting).to eq [unreviewed_change]
      end
    end
  end

  describe "#undo_items" do
    describe "check that we can find and report the entire undo set" do
      let!(:adder) { create :user, :editor }
      let!(:taxon) { create_taxon_version_and_change adder, 'Genus1' }

      context "when no others would be deleted" do
        it "returns a single taxon" do
          undo_items = described_class.first.undo_items

          expect(undo_items.size).to eq 1
          expect(undo_items.to_s).to match "Genus1"
          expect(undo_items.to_s).to match "change_type"
          expect(undo_items.to_s).to match "create"
        end
      end

      context "when undoing an older change would hit newer changes" do
        before do
          change = create :change, taxon: taxon, change_type: "update", user: create(:user)
          create :version, item: taxon, whodunnit: adder.id, change: change
          taxon.status = Status::HOMONYM
          taxon.save
        end

        it "returns multiple items" do
          undo_items = described_class.first.undo_items

          expect(undo_items.size).to eq 2
          expect(undo_items[0].to_s).to match "Genus1"
          expect(undo_items[0].to_s).to match "change_type"
          expect(undo_items[0].to_s).to match "Brian Fisher"
          expect(undo_items[0].to_s).to match "create"

          expect(undo_items[1].to_s).to match "Genus1"
          expect(undo_items[1].to_s).to match "update"
        end
      end
    end
  end
end
