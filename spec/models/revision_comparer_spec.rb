require "spec_helper"

describe RevisionComparer, :versioning do
  let(:item) { create :taxon_history_item, taxt: "initial content" }
  let(:item_id) { item.id }
  let(:model) { TaxonHistoryItem }

  describe "#most_recent" do
    context "when item exists" do
      it "returns the item (pretty much same as `Model#find`)" do
        most_recent = described_class.new(model, item.id).most_recent
        expect(most_recent).to eq item
      end
    end

    context "when item has been deleted" do
      before { item.destroy }

      it "returns the item (similar to `Model#find`, but searches in versions too)" do
        expect { model.find(item_id) }.to raise_error ActiveRecord::RecordNotFound

        most_recent = described_class.new(model, item_id).most_recent
        expect(most_recent.taxt).to eq "initial content"
      end
    end
  end

  describe "#diff_with and #selected" do
    let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second version") }.versions.last.id }
    let!(:selected_id) { item.tap { |item| item.update!(taxt: "last version") }.versions.last.id }

    describe "#diff_with" do
      subject(:comparer) { described_class.new model, item.id, nil, diff_with_id }

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
      subject(:comparer) { described_class.new model, item.id, selected_id }

      it "returns reified objects from the versions" do
        expect(comparer.selected.taxt).to eq "second version"
      end

      it "cannot be diffed by #html_split_diff" do
        expect(comparer.html_split_diff).to be nil
      end
    end

    describe "using #selected and #diff_with at the same time" do
      subject(:comparer) { described_class.new model, item.id, selected_id, diff_with_id }

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
    context "when item has been deleted" do
      let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second revision content") }.versions.last.id }

      before { item.destroy }

      it "returns a diff for side-by-side comparison" do
        comparer = described_class.new model, item_id, nil, diff_with_id
        diff = comparer.html_split_diff

        expect(diff.left).to match "<strong>initial</strong> content"
        expect(diff.right).to match "<strong>second revision</strong> content"
      end
    end
  end

  describe 'predicate methods' do
    let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second version") }.versions.last.id }
    let!(:selected_id) { item.tap { |item| item.update!(taxt: "last version") }.versions.last.id }

    let(:diff_with) { PaperTrail::Version.find(diff_with_id) }
    let(:selected) { PaperTrail::Version.find(selected_id) }

    context 'when nothing is loaded' do
      subject(:comparer) { described_class.new model, item.id }

      specify { expect(comparer.looking_at_most_recent?).to eq true }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq false }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq false }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq false }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end

    context 'when only `selected_id` is loaded' do
      subject(:comparer) { described_class.new model, item.id, selected_id }

      specify { expect(comparer.looking_at_most_recent?).to eq false }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq true }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq true }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq false }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end

    context 'when `selected_id` and `diff_with_id` are loaded' do
      subject(:comparer) { described_class.new model, item.id, selected_id, diff_with_id }

      specify { expect(comparer.looking_at_most_recent?).to eq false }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq false }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq true }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq true }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end
  end
end
