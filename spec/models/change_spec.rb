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
      let!(:taxon) { create :family }
      let!(:change) { create :change, taxon: taxon, change_type: "create", user: adder }

      before do
        create :version, item: taxon, whodunnit: adder.id, change: change
      end

      context "when no others would be deleted" do
        it "returns a single taxon" do
          expect(described_class.first.undo_items).to match(
            [
              { taxon: taxon, change_type: "added", date: anything, user: adder }
            ]
          )
        end
      end

      context "when undoing an older change would hit newer changes" do
        let!(:second_editor) { create :user }

        before do
          another_change = create :change, taxon: taxon, change_type: "update", user: second_editor
          create :version, item: taxon, whodunnit: adder.id, change: another_change
        end

        it "returns multiple items" do
          expect(described_class.first.undo_items).to match(
            [
              { taxon: taxon, change_type: "added", date: anything, user: adder },
              { taxon: taxon, change_type: "changed", date: anything, user: second_editor }
            ]
          )
        end
      end
    end
  end
end
