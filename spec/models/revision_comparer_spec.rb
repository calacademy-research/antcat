# frozen_string_literal: true

require 'rails_helper'

describe RevisionComparer, :versioning do
  let(:item) { create :taxon_history_item, taxt: "initial content" }
  let(:item_id) { item.id }
  let(:model) { HistoryItem }

  describe "#most_recent" do
    context "when item exists" do
      it "returns the item (pretty much same as `Model#find`)" do
        most_recent = described_class.new(model, item.id).most_recent
        expect(most_recent).to eq item
      end
    end

    context "when item has been deleted" do
      before { item.destroy! }

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
      let(:comparer) { described_class.new(model, item.id, nil, diff_with_id) }

      it "returns reified objects from the versions" do
        expect(comparer.diff_with.taxt).to eq "initial content"
      end
    end

    describe "#selected" do
      let(:comparer) { described_class.new(model, item.id, selected_id) }

      it "returns reified objects from the versions" do
        expect(comparer.selected.taxt).to eq "second version"
      end
    end

    describe "using #selected and #diff_with at the same time" do
      let(:comparer) { described_class.new(model, item.id, selected_id, diff_with_id) }

      it "handles #most_recent, #selected and #diff_with" do
        expect(comparer.diff_with.taxt).to eq "initial content"
        expect(comparer.selected.taxt).to eq "second version"
        expect(comparer.most_recent.taxt).to eq "last version"
      end
    end
  end

  describe 'predicate methods' do
    let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second version") }.versions.last.id }
    let!(:selected_id) { item.tap { |item| item.update!(taxt: "last version") }.versions.last.id }

    let(:diff_with) { PaperTrail::Version.find(diff_with_id) }
    let(:selected) { PaperTrail::Version.find(selected_id) }

    context 'when nothing is loaded' do
      let(:comparer) { described_class.new(model, item.id) }

      specify { expect(comparer.looking_at_most_recent?).to eq true }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq false }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq false }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq false }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end

    context 'when only `selected_id` is loaded' do
      let(:comparer) { described_class.new(model, item.id, selected_id) }

      specify { expect(comparer.looking_at_most_recent?).to eq false }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq true }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq true }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq false }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end

    context 'when `selected_id` and `diff_with_id` are loaded' do
      let(:comparer) { described_class.new(model, item.id, selected_id, diff_with_id) }

      specify { expect(comparer.looking_at_most_recent?).to eq false }
      specify { expect(comparer.looking_at_a_single_old_revision?).to eq false }
      specify { expect(comparer.revision_selected?(diff_with)).to eq false }
      specify { expect(comparer.revision_selected?(selected)).to eq true }
      specify { expect(comparer.revision_diff_with?(diff_with)).to eq true }
      specify { expect(comparer.revision_diff_with?(selected)).to eq false }
    end
  end
end
