require 'spec_helper'

describe Changes::UndosController do
  describe "GET show" do
    describe "check that we can find and report the entire undo set" do
      let!(:adder) { create :user, :editor }
      let!(:taxon) { create_taxon_version_and_change TaxonState::WAITING, adder, nil, 'Genus1' }

      before { sign_in adder }

      context "when no others would be deleted" do
        it "returns a single taxon" do
          get :show, params: { change_id: Change.first.id }

          undo_items = assigns :undo_items
          expect(undo_items.size).to eq 1
          expect(undo_items.to_s).to match "Genus1"
          expect(undo_items.to_s).to match "change_type"
          expect(undo_items.to_s).to match "create"
        end
      end

      context "when undoing an older change would hit newer changes" do
        before do
          change = create :change, taxon: taxon, change_type: "update"
          create :version, item: taxon, whodunnit: adder.id, change: change
          taxon.status = Status::HOMONYM
          taxon.save
        end

        it "returns multiple items" do
          get :show, params: { change_id: Change.first.id }

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
