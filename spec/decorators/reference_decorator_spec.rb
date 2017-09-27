require 'spec_helper'

describe ReferenceDecorator do
  let(:nil_decorator) { described_class.new nil }
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#format_reference_document_link" do
    let!(:reference) { build_stubbed :reference }

    before do
      allow(reference).to receive(:downloadable?).and_return true
      allow(reference).to receive(:url).and_return 'example.com'
    end

    it "creates a link" do
      expect(reference.decorate.format_reference_document_link)
        .to eq '<a href="example.com">PDF</a>'
    end
  end

  describe "#make_html_safe" do
    def make_html_safe string
      nil_decorator.send :make_html_safe, string
    end

    it "doesn't touch a string without HTML" do
      expect(make_html_safe 'string').to eq 'string'
    end

    it "leaves italics alone" do
      expect(make_html_safe '<i>string</i>').to eq '<i>string</i>'
    end

    it "leaves quotes alone" do
      expect(make_html_safe '"string"').to eq '"string"'
    end

    it "returns an html_safe string" do
      expect(make_html_safe '"string"').to be_html_safe
    end

    it "escapes other HTML" do
      expect(make_html_safe '<script>danger</script>')
        .to eq '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  describe "#formatted" do
    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }
      let(:reference) do
        create :unknown_reference, author_names: author_names,
          citation_year: "1874", title: "Les fourmis de la Suisse.", citation: '32 pp.'
      end

      it "escapes everything, buts let italics through" do
        reference.author_names = [create(:author_name, name: '<script>')]
        expect(reference.decorate.formatted)
          .to eq '&lt;script&gt; 1874. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the citation year" do
        reference.update_attribute :citation_year, '<script>'
        expect(reference.decorate.formatted)
          .to eq 'Ward, P. S. &lt;script&gt;. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the title" do
        reference.update_attribute :title, '<script>'
        expect(reference.decorate.formatted).to eq 'Ward, P. S. 1874. &lt;script&gt;. 32 pp.'
      end

      it "escapes the title but leave the italics alone" do
        reference.update_attribute :title, '*foo*<script>'
        expect(reference.decorate.formatted).to eq 'Ward, P. S. 1874. <i>foo</i>&lt;script&gt;. 32 pp.'
      end

      it "escapes the date" do
        reference.update_attribute :date, '1933>'
        expect(reference.decorate.formatted)
          .to eq 'Ward, P. S. 1874. Les fourmis de la Suisse. 32 pp. [1933&gt;]'
      end
    end
  end

  describe "#format_date" do
    def check_format_date date, expected
      expect(nil_decorator.send(:format_date, date)).to eq expected
    end

    it "uses ISO 8601 format for calendar dates" do
      check_format_date '20101213', '2010-12-13'
    end

    it "handles years without months and days" do
      check_format_date '201012', '2010-12'
    end

    it "handles years with months but without days" do
      check_format_date '2010', '2010'
    end

    it "handles missing dates" do
      check_format_date '', ''
    end
  end

  describe "#format_italics" do
    it "replaces asterisks with italics" do
      results = nil_decorator.send :format_italics, "*Lasius* queen".html_safe
      expect(results).to eq "<i>Lasius</i> queen"
      expect(results).to be_html_safe
    end

    context "when string isn't html_safe" do
      it "raises" do
        expect { nil_decorator.send :format_italics, 'roman' }
          .to raise_error "Can't call format_italics on an unsafe string"
      end
    end
  end

  describe "#format_review_state" do
    let(:reference) { build_stubbed :article_reference }

    context "when review_state is 'reviewed'" do
      before { reference.review_state = 'reviewed' }

      specify { expect(reference).to have_formatted_review_state 'Reviewed' }
    end

    context "when review_state is 'reviewing'" do
      before { reference.review_state = 'reviewing' }

      specify {expect(reference).to have_formatted_review_state 'Being reviewed' }
    end

    context "when review_state is 'none'" do
      before { reference.review_state = 'none' }

      specify {expect(reference).to have_formatted_review_state '' }
    end

    context "when review_state is empty string" do
      before { reference.review_state = '' }

      specify {expect(reference).to have_formatted_review_state '' }
    end

    context "when review_state is nil" do
      before { reference.review_state = nil }

      specify {expect(reference).to have_formatted_review_state '' }
    end
  end

  describe "a regression where a string should've been duped" do
    let(:reference) do
      create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: create(:journal, name: 'Ants'),
        series_volume_issue: '1:1', pagination: '2'
    end

    it "really should have been duped" do
      expect(reference.decorate.formatted).to eq 'Forel, A. 1874. Format. Ants 1:1:2.'
    end
  end
end
