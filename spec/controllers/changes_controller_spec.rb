require 'spec_helper'

describe ChangesController do
  describe "GET confirm_before_undo" do
    describe "check that we can find and report the entire undo set" do
      let!(:adder) { create :editor }
      let!(:taxon) { create_taxon_version_and_change :waiting, adder, nil, 'Genus1' }

      before { sign_in adder }

      context "when no others would be deleted" do
        it "returns a single taxon" do
          get :confirm_before_undo, id: Change.first.id

          undo_items = assigns :undo_items
          expect(undo_items.size).to eq 1
          expect(undo_items.to_s).to match "Genus1"
          expect(undo_items.to_s).to match "change_type"
          expect(undo_items.to_s).to match "create"
        end
      end

      context "when undoing an older change would hit newer changes" do
        before do
          change = create :change, user_changed_taxon_id: taxon.id, change_type: "update"
          create :version, item_id: taxon.id, whodunnit: adder.id, change_id: change.id
          taxon.status = 'homonym'
          taxon.save
        end

        it "returns multiple items" do
          get :confirm_before_undo, id: Change.first.id

          undo_items = assigns :undo_items

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
