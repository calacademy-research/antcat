require 'rails_helper'

describe ReferenceDecorator do
  describe 'notes' do
    describe '#public_notes, #editor_notes and #taxonomic_notes' do
      context 'with unsafe tags' do
        let!(:reference) do
          create :unknown_reference, public_notes: 'note <script>xss</script>',
            editor_notes: 'note <script>xss</script>', taxonomic_notes: 'note <script>xss</script>'
        end

        %i[public_notes editor_notes taxonomic_notes].each do |method_name|
          it "sanitizes them" do
            results = reference.decorate.public_send method_name
            expect(results).to_not include '<script>xss</script>'
            expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
            expect(results).to include 'note xss'
          end
        end
      end
    end
  end

  describe "#format_document_links" do
    let!(:reference) { build_stubbed :reference }

    before do
      allow(reference).to receive(:downloadable?).and_return true
      allow(reference).to receive(:url).and_return 'example.com'
    end

    it "creates a link" do
      expect(reference.decorate.format_document_links).
        to eq '<a class="pdf-link" href="example.com">PDF</a>'
    end
  end

  describe "#format_review_state" do
    let(:reference) { build_stubbed :article_reference }

    context "when review_state is 'reviewed'" do
      before { reference.review_state = 'reviewed' }

      specify { expect(reference.decorate.format_review_state).to eq 'Reviewed' }
    end

    context "when review_state is 'reviewing'" do
      before { reference.review_state = 'reviewing' }

      specify { expect(reference.decorate.format_review_state).to eq 'Being reviewed' }
    end

    context "when review_state is 'none'" do
      before { reference.review_state = 'none' }

      specify { expect(reference.decorate.format_review_state).to eq 'Not reviewed' }
    end
  end

  describe '#format_plain_text_title' do
    context 'with unsafe tags' do
      let!(:reference) { create :article_reference, title: '<script>xss</script>' }

      it "sanitizes them" do
        results = reference.decorate.format_plain_text_title
        expect(results).to_not include '<script>xss</script>'
        expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
        expect(results).to include 'xss'
      end
    end
  end
end
