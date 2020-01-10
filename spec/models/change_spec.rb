require 'rails_helper'

describe Change do
  include ActiveSupport::Testing::TimeHelpers

  describe "validations" do
    it { is_expected.to validate_presence_of(:user).on(:create) }
  end

  describe 'relations' do
    it { is_expected.to have_many(:versions).dependent(false) }
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

  describe '#can_be_undone?' do
    context 'when change was created after the last allowed undo date' do
      let!(:new_change) do
        travel_to(described_class::DISALLOW_UNDOS_CREATED_BEFORE + 1.day) do
          create :change
        end
      end

      it 'can be undone' do
        expect(new_change.can_be_undone?).to eq true
      end
    end

    context 'when change was created before the last allowed undo date' do
      let!(:too_old_change) do
        travel_to(described_class::DISALLOW_UNDOS_CREATED_BEFORE - 1.day) do
          create :change
        end
      end

      it 'cannot be undone' do
        expect(too_old_change.can_be_undone?).to eq false
      end
    end
  end

  describe '#undo' do
    context 'when change is not allowed to be undone' do
      let!(:too_old_change) do
        travel_to(described_class::DISALLOW_UNDOS_CREATED_BEFORE - 1.day) do
          create :change
        end
      end

      specify { expect { too_old_change.undo }.to raise_error('cannot be undone') }
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
