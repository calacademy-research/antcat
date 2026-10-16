# frozen_string_literal: true

require 'rails_helper'

describe RevisionPresenter do
  describe "#html_split_diff", :versioning do
    subject(:presenter) { described_class.new(comparer: comparer) }

    let(:item) { create :history_item, :taxt, taxt: "initial content" }
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
            to raise_error(NoMethodError, /undefined method .left. for nil/)
          expect { presenter.right_side_diff }.
            to raise_error(NoMethodError, /undefined method .right. for nil/)
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

  describe "#render_revision" do
    # Built, not created, so that callbacks do not clean up the taxt.
    let(:item) { build :history_item, :taxt, taxt: "<script>alert(1)</script>" }
    let(:comparer) { instance_double(RevisionComparer) }

    context "without a template" do
      let(:presenter) { described_class.new(comparer: comparer) }

      it "escapes the revision" do
        rendered = presenter.render_revision(item, view_context: nil)

        expect(rendered).to be_html_safe
        expect(rendered).to start_with "<pre>"
        expect(rendered).to include "alert(1)"
        expect(rendered).not_to include "<script>"
      end
    end

    context "when rendering the template raises" do
      let(:presenter) { described_class.new(comparer: comparer, template: "some/template") }
      let(:view_context) { instance_double(ActionView::Base) }

      before do
        allow(view_context).to receive(:render).and_raise(StandardError, "<img src=x onerror=alert(1)>")
      end

      it "escapes the error message and the revision" do
        rendered = presenter.render_revision(item, view_context: view_context)

        expect(rendered).to include "&lt;img src=x onerror=alert(1)&gt;"
        expect(rendered).to include "<br><br><pre>"
        expect(rendered).not_to include "<img"
        expect(rendered).not_to include "<script>"
      end
    end
  end
end
