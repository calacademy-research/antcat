require 'rails_helper'

describe RevisionPresenter do
  describe "#html_split_diff", :versioning do
    subject(:presenter) { described_class.new(comparer: comparer) }

    let(:item) { create :taxon_history_item, taxt: "initial content" }
    let(:model) { TaxonHistoryItem }

    describe "comparing versions" do
      let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second version") }.versions.last.id }
      let!(:selected_id) { item.tap { |item| item.update!(taxt: "last version") }.versions.last.id }

      describe "with `diff_with` only" do
        let(:comparer) { RevisionComparer.new(model, item.id, nil, diff_with_id) }

        specify do
          expect(comparer.diff_with.taxt).to eq "initial content"

          diff = presenter.html_split_diff
          expect(diff.left).to match "<strong>initial content</strong>"
          expect(diff.right).to match "<strong>last version</strong>"
        end
      end

      describe "with `selected` only" do
        let(:comparer) { RevisionComparer.new(model, item.id, selected_id) }

        specify do
          expect(comparer.selected.taxt).to eq "second version"
          expect(presenter.html_split_diff).to eq nil
        end
      end

      describe "with `selected` and `diff_with` at the same time" do
        let(:comparer) { RevisionComparer.new(model, item.id, selected_id, diff_with_id) }

        specify do
          expect(comparer.diff_with.taxt).to eq "initial content"
          expect(comparer.selected.taxt).to eq "second version"
          expect(comparer.most_recent.taxt).to eq "last version"

          diff = presenter.html_split_diff
          expect(diff.left).to match "<strong>initial content</strong>"
          expect(diff.right).to match "<strong>second version</strong>"
        end
      end
    end

    context "when item has been deleted" do
      let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second revision content") }.versions.last.id }
      let(:comparer) { RevisionComparer.new(model, item.id, nil, diff_with_id) }

      before do
        item.destroy!
      end

      it "returns a diff for side-by-side comparison" do
        diff = presenter.html_split_diff
        expect(diff.left).to match "<strong>initial</strong> content"
        expect(diff.right).to match "<strong>second revision</strong> content"
      end
    end
  end
end
