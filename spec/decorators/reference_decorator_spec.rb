# frozen_string_literal: true

require 'rails_helper'

describe ReferenceDecorator do
  subject(:decorated) { reference.decorate }

  describe 'notes' do
    describe '#public_notes, #editor_notes and #taxonomic_notes' do
      context 'with unsafe tags' do
        let(:reference) do
          create :any_reference, public_notes: 'note <script>xss</script>',
            editor_notes: 'note <script>xss</script>', taxonomic_notes: 'note <script>xss</script>'
        end

        %i[public_notes editor_notes taxonomic_notes].each do |method_name|
          it "sanitizes them" do
            results = decorated.public_send method_name
            expect(results).to_not include '<script>xss</script>'
            expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
            expect(results).to include 'note xss'
          end
        end
      end
    end
  end

  describe "#format_document_links" do
    let(:reference) { build_stubbed :reference }

    before do
      allow(reference).to receive(:downloadable?).and_return true
      allow(reference).to receive(:routed_url).and_return 'example.com'
    end

    it "creates a link" do
      expect(decorated.format_document_links).
        to eq '<a class="pdf-link" href="example.com">PDF</a>'
    end
  end

  describe "#format_review_state" do
    context "when `review_state` is 'reviewed'" do
      let(:reference) { build_stubbed :any_reference, review_state: 'reviewed' }

      specify { expect(decorated.format_review_state).to eq 'Reviewed' }
    end

    context "when `review_state` is 'reviewing'" do
      let(:reference) { build_stubbed :any_reference, review_state: 'reviewing' }

      specify { expect(decorated.format_review_state).to eq 'Being reviewed' }
    end

    context "when `review_state` is 'none'" do
      let(:reference) { build_stubbed :any_reference, review_state: 'none' }

      specify { expect(decorated.format_review_state).to eq 'Not reviewed' }
    end
  end

  describe '#format_title' do
    context 'with unsafe tags' do
      let(:reference) { create :any_reference, title: '<script>xss</script>' }

      it "sanitizes them" do
        results = decorated.format_title
        expect(results).to_not include '<script>xss</script>'
        expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
        expect(results).to include 'xss'
      end
    end
  end
end
