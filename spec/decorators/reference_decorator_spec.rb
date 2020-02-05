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

  describe "#plain_text" do
    context "with unsafe tags" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }
      let(:reference) do
        create :unknown_reference, author_names: author_names,
          citation_year: "1874", title: "Les fourmis de la Suisse.", citation: '32 pp.'
      end

      it "escapes everything, buts let italics through" do
        reference.author_names = [create(:author_name, name: '<script>')]
        expect(reference.decorate.plain_text).
          to eq '1874. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the citation year" do
        reference.update!(citation_year: '<script>')
        expect(reference.decorate.plain_text).
          to eq 'Ward, P. S. . Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the title" do
        reference.update!(title: '*foo*<script>')
        expect(reference.decorate.plain_text).to eq 'Ward, P. S. 1874. foo. 32 pp.'
      end
    end
  end

  describe "#expandable_reference and #expanded_reference" do
    context 'with unsafe tags' do
      let!(:reference) do
        author_name = create :author_name, name: '<script>xss</script>'
        journal = create :journal, name: '<script>xss</script>'
        create :article_reference, journal: journal, pagination: '<script>xss</script>',
          series_volume_issue: '<script>xss</script>', title: '<script>xss</script>',
          citation_year: '<script>xss</script>', author_names: [author_name],
          author_names_suffix: '<script>xss</script>', date: '<script>xss</script>'
      end

      describe '#expandable_reference' do
        it "sanitizes them" do
          results = reference.decorate.expandable_reference
          expect(results).to_not include '<script>xss</script>'

          # NOTE: `.to include`, not `.to_not include` since it's wrapped inside the title attribute of the tooltip.
          expect(results).to include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end

      describe '#expanded_reference' do
        it "sanitizes them" do
          results = reference.decorate.expanded_reference
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is online early' do
      let(:reference) { create :article_reference, online_early: true }

      specify { expect(reference.decorate.expandable_reference).to include ' [online early]' }
      specify { expect(reference.decorate.expanded_reference).to include ' [online early]' }
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
