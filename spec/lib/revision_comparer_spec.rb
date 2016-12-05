require "spec_helper"

describe RevisionComparer, versioning: true do
  let(:item) { create :taxon_history_item, taxt: "initial content" }
  let(:item_id) { item.id }
  let(:model) { TaxonHistoryItem }

  describe "#current" do
    context "item exists" do
      it "returns the item (like pretty much same as Model#find)" do
        current = RevisionComparer.new(model, item.id).current
        expect(current).to eq item
      end
    end

    context "item has been deleted" do
      before { item.destroy }

      it "returns the item (like pretty much same as Model#find)" do
        expect { model.find(item_id) }.to raise_error ActiveRecord::RecordNotFound

        current = RevisionComparer.new(model, item_id).current
        expect(current.taxt).to eq "initial content"
      end
    end
  end

  describe "#html_split_diff" do
    context "item has been deleted" do
      before do
        item.taxt = "second revision content"
        item.save!
        @selected_id = item.versions.last.id
        item.destroy
      end

      it "returns a diff for side-by-side comparison" do
        comparer = RevisionComparer.new model, item_id, @selected_id
        diff = comparer.html_split_diff

        expect(diff.left).to match "<strong>initial</strong> content"
        expect(diff.right).to match "<strong>second revision</strong> content"
      end
    end
  end
end
