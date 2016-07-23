require 'spec_helper'

describe "ReferenceDecorator formerly ReferenceKey" do
  before do
    @bolton = create :author_name, name: 'Bolton, B.'
    @fisher = create :author_name, name: 'Fisher, B.'
    @ward = create :author_name, name: 'Ward, P.S.'
  end

  # Representing as a string
  describe "#key" do
    it "is blank if a new record" do
      expect(BookReference.new.decorate.key).to eq ''
    end

    it "Citation year with extra" do
      reference = create :article_reference, author_names: [@bolton], citation_year: '1970a ("1971")'
      expect(reference.decorate.key).to eq 'Bolton, 1970a'
    end

    it "No authors" do
      reference = create :article_reference,
        author_names: [],
        citation_year: '1970a'
      expect(reference.decorate.key).to eq '[no authors], 1970a'
    end

    it "One author" do
      reference = create :article_reference,
        author_names: [@bolton],
        citation_year: '1970a'
      expect(reference.decorate.key).to eq 'Bolton, 1970a'
    end

    it "Two authors" do
      reference = create :article_reference,
        author_names: [@bolton, @fisher],
        citation_year: '1970a'
      expect(reference.decorate.key).to eq 'Bolton & Fisher, 1970a'
    end

    it "Three authors" do
      reference = create :article_reference,
        author_names: [@bolton, @fisher, @ward],
        citation_year: '1970a'
      expect(reference.decorate.key).to eq 'Bolton, Fisher & Ward, 1970a'
    end
  end

  describe "#to_link" do
    before do
      @latreille = create :author_name, name: 'Latreille, P. A.'
      science = create :journal, name: 'Science'
      @reference = create :article_reference,
        author_names: [@latreille],
        citation_year: '1809',
        title: "*Atta*",
        journal: science,
        series_volume_issue: '(1)',
        pagination: '3'
      allow(@reference).to receive(:url).and_return 'example.com'
    end

    it "creates a link to the reference" do
      allow(@reference).to receive(:downloadable?).and_return true
      expect(@reference.decorate.to_link).to eq(
        %{<span class="reference_key_and_expansion">} +
          %{<a class="reference_key" title="Latreille, P. A. 1809. Atta. Science (1):3." href="#">Latreille, 1809</a>} +
          %{<span class="reference_key_expansion">} +
            %{<span class="reference_key_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span>} +
            %{ } +
            %{<a class="document_link" target="_blank" href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a> } +
            %{<a class="document_link" target="_blank" href="example.com">PDF</a>} +
            %{ } +
            %{<a class="goto_reference_link" target="_blank" href="/references/#{@reference.id}">#{@reference.id}</a>} +
          %{</span>} +
        %{</span>}
      )
    end

    it "creates a link to the reference without the PDF link if the user isn't logged in" do
      allow(@reference).to receive(:downloadable?).and_return false
      expect(@reference.decorate.to_link).to eq(
        %{<span class="reference_key_and_expansion">} +
          %{<a class="reference_key" title="Latreille, P. A. 1809. Atta. Science (1):3." href="#">Latreille, 1809</a>} +
          %{<span class="reference_key_expansion">} +
            %{<span class="reference_key_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span> } +
            %{<a class="document_link" target="_blank" href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a> } +
            %{<a class="goto_reference_link" target="_blank" href="/references/#{@reference.id}">#{@reference.id}</a>} +
          %{</span>} +
        %{</span>}
      )
    end

    context "when expansion is not desired" do
      context "PDF is not available to the user" do
        it "doesn't include the PDF link" do
          allow(@reference).to receive(:downloadable?).and_return false
          expect(@reference.decorate.to_link(expansion: false)).to eq(
            %{<a target="_blank" title="Latreille, P. A. 1809. Atta. Science (1):3." } +
            %{href="http://antcat.org/references/#{@reference.id}">Latreille, 1809</a>} +
            %{ <a class="document_link" target="_blank" } +
            %{href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a>}
          )
        end
      end

      context "PDF is available to the user" do
        it "includes the PDF link" do
          allow(@reference).to receive(:downloadable?).and_return true
          expect(@reference.decorate.to_link(expansion: false)).to eq(
            %{<a target="_blank" title="Latreille, P. A. 1809. Atta. Science (1):3." } +
            %{href="http://antcat.org/references/#{@reference.id}">Latreille, 1809</a>} +
            %{ <a class="document_link" target="_blank" href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a>} +
            %{ <a class="document_link" target="_blank" href="example.com">PDF</a>}
          )
        end
      end
    end

    describe "Handling quotes in the title" do
      it "escapes them" do
        @reference = create :unknown_reference, author_names: [@latreille], citation_year: '1809', title: '"Atta"'
        expect(@reference.decorate.to_link(expansion: false)).to eq(
          %{<a target="_blank" title="Latreille, P. A. 1809. "Atta". New York." href="http://antcat.org/references/#{@reference.id}">Latreille, 1809</a>}
        )
      end
    end
  end
end
