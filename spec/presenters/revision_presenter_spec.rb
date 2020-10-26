# frozen_string_literal: true

require 'rails_helper'

describe RevisionPresenter do
  describe "#html_split_diff", :versioning do
    subject(:presenter) { described_class.new(comparer: comparer) }

    let(:item) { create :history_item, taxt: "initial content" }
    let(:model) { HistoryItem }

    describe "comparing versions" do
      let!(:diff_with_id) { item.tap { |item| item.update!(taxt: "second version") }.versions.last.id }
      let!(:selected_id) { item.tap { |item| item.update!(taxt: "last version") }.versions.last.id }

      describe "with `diff_with` only" do
        let(:comparer) { RevisionComparer.new(model, item.id, nil, diff_with_id) }

        specify do
          expect(comparer.diff_with.taxt).to eq "initial content"

          expect(presenter.left_side_diff).to match "<strong>initial content</strong>"
          expect(presenter.right_side_diff).to match "<strong>last version</strong>"
        end
      end

      describe "with `selected` only" do
        let(:comparer) { RevisionComparer.new(model, item.id, selected_id) }

        specify do
          expect(comparer.selected.taxt).to eq "second version"
          expect { presenter.left_side_diff }.
            to raise_error(NoMethodError, "undefined method `left' for nil:NilClass")
          expect { presenter.right_side_diff }.
            to raise_error(NoMethodError, "undefined method `right' for nil:NilClass")
        end
      end

      describe "with `selected` and `diff_with` at the same time" do
        let(:comparer) { RevisionComparer.new(model, item.id, selected_id, diff_with_id) }

        specify do
          expect(comparer.diff_with.taxt).to eq "initial content"
          expect(comparer.selected.taxt).to eq "second version"
          expect(comparer.most_recent.taxt).to eq "last version"

          expect(presenter.left_side_diff).to match "<strong>initial content</strong>"
          expect(presenter.right_side_diff).to match "<strong>second version</strong>"
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
        expect(presenter.left_side_diff).to match "<strong>initial</strong> content"
        expect(presenter.right_side_diff).to match "<strong>second revision</strong> content"
      end
    end
  end
end
