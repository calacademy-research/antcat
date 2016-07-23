require 'spec_helper'

describe ReferenceDecorator do
  let(:nil_decorator) { ReferenceDecorator.new nil }
  let(:journal) { create :journal, name: "Neue Denkschriften" }
  let(:author_name) { create :author_name, name: "Forel, A." }

  # PDF link formatting
  describe "#format_reference_document_link" do
    it "creates a link" do
      reference = create :reference
      allow(reference).to receive(:downloadable?).and_return true
      allow(reference).to receive(:url).and_return 'example.com'
      expect(reference.decorate.format_reference_document_link)
        .to eq '<a class="document_link" target="_blank" href="example.com">PDF</a>'
    end
  end

  describe "#make_html_safe" do
    it "doesn't touch a string without HTML" do
      expect(nil_decorator.send(:make_html_safe, 'string')).to eq 'string'
    end

    it "leaves italics alone" do
      expect(nil_decorator.send(:make_html_safe, '<i>string</i>')).to eq '<i>string</i>'
    end

    it "leaves quotes alone" do
      expect(nil_decorator.send(:make_html_safe, '"string"')).to eq '"string"'
    end

    it "returns an html_safe string" do
      expect(nil_decorator.send(:make_html_safe, '"string"')).to be_html_safe
    end

    it "escapes other HTML" do
      expect(nil_decorator.send(:make_html_safe, '<script>danger</script>'))
        .to eq '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  describe "#format" do
    it "formats the reference" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      string = reference.decorate.format
      expect(string).to be_html_safe
      expect(string).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "adds a period after the title if none exists" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "doesn't add a period after the author_names' suffix" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      reference.update_attribute :author_names_suffix, ' (ed.)'
      expect(reference.decorate.format)
        .to eq 'Forel, A. (ed.) 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "doesn't add a period after the title if it ends with a question mark" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse?",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse? Neue Denkschriften 26:1-452.'
    end

    it "doesn't add a period after the title if it ends with an exclamation mark" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse!",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse! Neue Denkschriften 26:1-452.'
    end

    it "doesn't add a period after the title if there's already one" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "adds a period after the citation if none exists" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "doesn't add a period after the citation if there's already one" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452."
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "separates the publisher and the pagination with a comma" do
      publisher = create :publisher
      reference = create :book_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        publisher: publisher, pagination: "22 pp."
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. New York: Wiley, 22 pp.'
    end

    it "formats unknown references" do
      reference = create :unknown_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        citation: 'New York'
      expect(reference.decorate.format).to eq 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
    end

    it "formats nested references" do
      reference = create :book_reference,
        author_names: [create(:author_name, name: 'Mayr, E.')],
        citation_year: '2010',
        title: 'Ants I have known',
        publisher: create(:publisher, name: 'Wiley', place: create(:place, name: 'New York')),
        pagination: '32 pp.'
      nested_reference = create :nested_reference, nesting_reference: reference,
        author_names: [author_name], title: 'Les fourmis de la Suisse',
        citation_year: '1874', pages_in: 'Pp. 32-45 in'
      expect(nested_reference.decorate.format).to eq(
        'Forel, A. 1874. Les fourmis de la Suisse. Pp. 32-45 in Mayr, E. 2010. Ants I have known. New York: Wiley, 32 pp.'
      )
    end

    it "formats a citation_string correctly if the publisher doesn't have a place" do
      publisher = Publisher.create! name: "Wiley"
      reference = create :book_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        publisher: publisher,
        pagination: "22 pp."
      expect(reference.decorate.format)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Wiley, 22 pp.'
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }
      let(:reference) { create :unknown_reference, author_names: author_names,
        citation_year: "1874", title: "Les fourmis de la Suisse.", citation: '32 pp.' }

      it "escapes everything, buts let italics through" do
        reference.author_names = [create(:author_name, name: '<script>')]
        expect(reference.decorate.format)
          .to eq '&lt;script&gt; 1874. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the citation year" do
        reference.update_attribute :citation_year, '<script>'
        expect(reference.decorate.format)
          .to eq 'Ward, P. S. &lt;script&gt;. Les fourmis de la Suisse. 32 pp.'
      end

      it "escapes the title" do
        reference.update_attribute :title, '<script>'
        expect(reference.decorate.format).to eq 'Ward, P. S. 1874. &lt;script&gt;. 32 pp.'
      end

      it "escapes the title but leave the italics alone" do
        reference.update_attribute :title, '*foo*<script>'
        expect(reference.decorate.format).to eq 'Ward, P. S. 1874. <i>foo</i>&lt;script&gt;. 32 pp.'
      end

      it "escapes the date" do
        reference.update_attribute :date, '1933>'
        expect(reference.decorate.format)
          .to eq 'Ward, P. S. 1874. Les fourmis de la Suisse. 32 pp. [1933&gt;]'
      end

      it "escapes the citation in an article reference" do
        reference = create :article_reference,
          title: 'Ants are my life', author_names: author_names,
          journal: create(:journal, name: '<script>'), citation_year: '2010d', series_volume_issue: '<', pagination: '>'
        expect(reference.decorate.format)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &lt;script&gt; &lt;:&gt;.'
      end

      it "escapes the citation in a book reference" do
        reference = create :book_reference,
          citation_year: '2010d',
          title: 'Ants are my life',
          author_names: author_names,
          publisher: create(:publisher, name: '<', place: create(:place, name: '>')),
          pagination: '>'
        expect(reference.decorate.format)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &gt;: &lt;, &gt;.'
      end

      it "escapes the citation in an unknown reference" do
        reference = create :unknown_reference,
          title: 'Ants are my life',
          citation_year: '2010d',
          author_names: author_names,
          citation: '>'
        expect(reference.decorate.format).to eq 'Ward, P. S. 2010d. Ants are my life. &gt;.'
      end

      it "escapes the citation in a nested reference" do
        nested_reference = create :unknown_reference,
          title: "Ants are my life",
          citation_year: '2010d',
          author_names: author_names
        reference = create :nested_reference,
          title: "Ants are my life",
          citation_year: '2010d',
          author_names: author_names,
          pages_in: '>',
          nesting_reference: nested_reference
        expect(reference.decorate.format)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &gt; Ward, P. S. 2010d. Ants are my life. New York.'
      end
    end

    describe "Italicizing title and citation" do
      it "returns an html_safe string" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '*Tapinoma*'
        expect(reference.decorate.format).to be_html_safe
      end

      it "italicizes the title and citation" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '*Tapinoma*'
        expect(reference.decorate.format).to eq "2010d. <i>Tapinoma</i>. <i>Ants</i>."
      end

      it "italicizes the title even with two italicized words" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: 'Ants',
          title: 'Note on a new northern cutting ant, *Atta* *septentrionalis*.'
        expect(reference.decorate.format)
          .to eq "2010d. Note on a new northern cutting ant, <i>Atta</i> <i>septentrionalis</i>. Ants."
      end

      it "allows existing italics in title and citation" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '<i>Tapinoma</i>'
        expect(reference.decorate.format).to eq "2010d. <i>Tapinoma</i>. <i>Ants</i>."
      end

      it "escapes other HTML in title and citation" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '<span>Tapinoma</span>'
        expect(reference.decorate.format)
          .to eq "2010d. &lt;span&gt;Tapinoma&lt;/span&gt;. <i>Ants</i>."
      end

      it "doesn't escape et al. in citation" do
        reference = create :unknown_reference,
          author_names: [],
          citation_year: '2010',
          citation: 'Ants <i>et al.</i>',
          title: 'Tapinoma'
        expect(reference.decorate.format).to eq "2010. Tapinoma. Ants <i>et al.</i>."
      end

      it "doesn't escape et al. in citation for a missing reference" do
        reference = create :missing_reference,
          author_names: [],
          citation_year: '2010',
          citation: 'Ants <i>et al.</i>',
          title: 'Tapinoma'
        expect(reference.decorate.format).to eq "2010. Tapinoma. Ants <i>et al.</i>"
      end
    end

    describe "#format_year" do
      it "leaves quotes (and italics) alone, but escapes other HTML" do
        reference = create :unknown_reference,
          citation_year: '2010 ("2011")',
          author_names: [],
          citation: 'Ants',
          title: 'Tapinoma'
        string = reference.decorate.send :format_year
        expect(string).to eq '2010 ("2011")'
        expect(string).to be_html_safe
      end
    end

    describe "#format_author_names" do
      it "doesn't escape quotes and italics, should escape everything else" do
        reference = create :unknown_reference,
          author_names: [author_name],
          citation: 'Ants',
          title: 'Tapinoma',
          author_names_suffix: ' <i>et al.</i>'
        string = reference.decorate.send :format_author_names
        expect(string).to eq 'Forel, A. <i>et al.</i>'
        expect(string).to be_html_safe
      end
    end
  end

  it "doesn't have a space at the beginning when there are no authors" do
    reference = create :unknown_reference,
      citation_year: '2010d',
      author_names: [],
      citation: 'Ants',
      title: 'Tapinoma'
    expect(reference.decorate.format).to eq "2010d. Tapinoma. Ants."
  end

  describe "formatting the date" do
    it "uses ISO 8601 format for calendar dates" do
      make '20101213'
      check ' [2010-12-13]'
    end

    it "handles years without months and days" do
      make '201012'
      check ' [2010-12]'
    end

    it "handles years with months but without days" do
      make '2010'
      check ' [2010]'
    end

    it "handles missing date" do
      make nil
      check ''
    end

    it "handle missing date" do
      make ''
      check ''
    end

    it "handles dates with other symbols/characters" do
      make '201012>'
      check ' [2010-12&gt;]'
    end

    def make date
      @reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452.",
        date: date
    end

    def check expected
      expect(@reference.decorate.format)
        .to eq "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.#{expected}"
    end
  end

  describe "#format_italics" do
    it "replaces asterisks and bars with italics" do
      string = nil_decorator.send :format_italics, "|Hymenoptera| *Formicidae*".html_safe
      expect(string).to eq "<i>Hymenoptera</i> <i>Formicidae</i>"
      expect(string).to be_html_safe
    end

    #ZZZ
    context "string isn't html_safe" do
    it "raises" do
      expect { nil_decorator.send :format_italics, 'roman' }.to raise_error
    end
    end
  end

  describe "#format_inline_citation" do
    context "with links" do
      it "defers nonmissing references to the key" do
        key = double
        reference = create :article_reference
        decorated = reference.decorate
        expect(decorated).to receive(:to_link).and_return key

        decorated.format_inline_citation
      end

      it "just outputs the citation for a MissingReference" do
        reference = create :missing_reference, citation: 'foo'
        expect(reference.decorate.format_inline_citation).to eq 'foo'
      end
    end

    context "without links" do
      it "nonmissing references should defer to the key" do
        key = double
        reference = create :article_reference
        decorated = reference.decorate
        expect(decorated).to receive(:format_author_last_names).and_return key

        decorated.format_inline_citation_without_links
      end
    end
  end

  describe "#format_timestamp" do
    it "uses a short format" do
      expect(nil_decorator.send(:format_timestamp, Time.parse('2001-1-2'))).to eq '2001-01-02'
    end
  end

  # returns the display string for a review status
  describe "#format_review_state" do
    #ZZZ unindent
      it "handles 'reviewed'" do
        reference = create :reference, review_state: 'reviewed'
        expect(reference.decorate.format_review_state).to eq 'Reviewed'
      end

      it "handles 'reviewing'" do
        reference = create :reference, review_state: 'reviewing'
        expect(reference.decorate.format_review_state).to eq 'Being reviewed'
      end

      it "handles 'none'" do
        reference = create :reference, review_state: 'none'
        expect(reference.decorate.format_review_state).to eq ''
      end

      it "handles empty states" do
        reference = create :reference, review_state: ''
        expect(reference.decorate.format_review_state).to eq ''
      end

      it "handles nil" do
        reference = create :reference, review_state: nil
        expect(reference.decorate.format_review_state).to eq ''
      end
  end

  describe "A regression where a string should've been duped" do
    it "really should have been duped" do
      journal = create :journal, name: 'Ants'
      reference = create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
      expect(reference.decorate.format).to eq 'Forel, A. 1874. Format. Ants 1:1:2.'
    end
  end

  describe "#format_authorship_html" do
    it "formats references into HTML, with rollover" do
      journal = create :journal, name: 'Ants'
      reference = create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
      expected = '<span title="Forel, A. 1874. Format. Ants 1:1:2.">Forel, 1874</span>'
      expect(reference.decorate.format_authorship_html).to be === expected
    end
  end

  describe "Using ReferenceFormatterCache" do
    it "returns an html_safe string from the cache" do
      reference = create :article_reference
      ReferenceFormatterCache.instance.populate reference
      expect(reference.decorate.format).to be_html_safe
    end

    describe "#format vs. #format!" do
      describe "#format" do
        it "reads from the cache" do
          reference = create :article_reference
          expect(ReferenceFormatterCache.instance).to receive(:get).and_return 'Cache'
          expect(ReferenceFormatterCache.instance).not_to receive(:set)
          reference.decorate.format
        end

        it "populates and set the cache when it's empty" do
          reference = create :article_reference
          expect(ReferenceFormatterCache.instance).to receive(:get).and_return nil
          expect_any_instance_of(ReferenceDecorator).to receive(:format!).and_return 'Cache'
          expect(ReferenceFormatterCache.instance).to receive(:set).with(reference, 'Cache', :formatted_cache)
          reference.decorate.format
        end
      end

      describe "#format!" do
        it "doesn't touch the cache" do
          reference = create :article_reference
          expect(ReferenceFormatterCache.instance).not_to receive(:get)
          expect(ReferenceFormatterCache.instance).not_to receive(:set)
          reference.decorate.format!
        end
      end
    end

    describe "Inline citation cache" do
      describe "Current user" do
        it "doesn't set the cache if there's no current user" do
          reference = create :article_reference
          expect(ReferenceFormatterCache.instance.get(reference, :formatted_cache)).to be_nil
          expect(ReferenceFormatterCache.instance.get(reference, :inline_citation_cache)).to be_nil
          reference.decorate.format_inline_citation
          expect(ReferenceFormatterCache.instance.get(reference, :formatted_cache)).not_to be_nil
          expect(ReferenceFormatterCache.instance.get(reference, :inline_citation_cache)).to be_nil
        end
      end
    end
  end
end
