require "spec_helper"

describe RevisionComparer, versioning: true do
  let(:item) { create :taxon_history_item, taxt: "initial content" }
  let(:item_id) { item.id }
  let(:model) { TaxonHistoryItem }

  describe "#most_recent" do
    context "item exists" do
      it "returns the item (pretty much same as Model#find)" do
        most_recent = RevisionComparer.new(model, item.id).most_recent
        expect(most_recent).to eq item
      end
    end

    context "item has been deleted" do
      before { item.destroy }

      it "returns the item (similar to Model#find, but searches in versions too)" do
        expect { model.find(item_id) }.to raise_error ActiveRecord::RecordNotFound

        most_recent = RevisionComparer.new(model, item_id).most_recent
        expect(most_recent.taxt).to eq "initial content"
      end
    end
  end

  describe "#diff_with and #selected" do
    before do
      item.taxt = "second version"
      item.save!
      @diff_with_id = PaperTrail::Version.last.id

      item.taxt = "last version"
      item.save!
      @selected_id = PaperTrail::Version.last.id
    end

    describe "#diff_with" do
      let(:comparer) { RevisionComparer.new model, item.id, nil, @diff_with_id }

      it "returns reified objects from the versions" do
        expect(comparer.diff_with.taxt).to eq "initial content"
      end

      it "plays nice with #html_split_diff" do
        diff = comparer.html_split_diff
        expect(diff.left).to match "<strong>initial content</strong>"
        expect(diff.right).to match "<strong>last version</strong>"
      end
    end

    describe "#selected" do
      let(:comparer) { RevisionComparer.new model, item.id, @selected_id }

      it "returns reified objects from the versions" do
        expect(comparer.selected.taxt).to eq "second version"
      end

      it "cannot be diffed by #html_split_diff" do
        expect(comparer.html_split_diff).to be nil
      end
    end

    context "using #selected and #diff_with at the same time" do
      let(:comparer) { RevisionComparer.new model, item.id, @selected_id, @diff_with_id }

      it "handles #most_recent, #selected and #diff_with" do
        expect(comparer.diff_with.taxt).to eq "initial content"
        expect(comparer.selected.taxt).to eq "second version"
        expect(comparer.most_recent.taxt).to eq "last version"
      end

      it "plays nice with #html_split_diff" do
        diff = comparer.html_split_diff
        expect(diff.left).to match "<strong>initial content</strong>"
        expect(diff.right).to match "<strong>second version</strong>"
      end
    end
  end

  describe "#html_split_diff" do
    context "item has been deleted" do
      before do
        item.taxt = "second revision content"
        item.save!
        @diff_with_id = item.versions.last.id
        item.destroy
      end

      it "returns a diff for side-by-side comparison" do
        comparer = RevisionComparer.new model, item_id, nil, @diff_with_id
        diff = comparer.html_split_diff

        expect(diff.left).to match "<strong>initial</strong> content"
        expect(diff.right).to match "<strong>second revision</strong> content"
      end
    end
  end
end
