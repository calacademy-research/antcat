# TODO move file.

require 'spec_helper'

describe "ReferenceDecorator" do
  let(:bolton) { create :author_name, name: 'Bolton, B.' }
  let(:fisher) { create :author_name, name: 'Fisher, B.' }
  let(:ward) { create :author_name, name: 'Ward, P.S.' }

  describe "#key" do
      it "raises because it's impossible to search for it" do
        expect { BookReference.new.decorate.key }.to raise_error
      end
  end

  # Representing as a string
  describe "#keey" do
    it "Citation year with extra" do
      reference = create :article_reference,
        author_names: [bolton],
        citation_year: '1970a ("1971")'
      expect(reference.decorate.keey).to eq 'Bolton, 1970a'
    end

    it "No authors" do
      reference = create :article_reference,
        author_names: [],
        citation_year: '1970a'
      expect(reference.decorate.keey).to eq '[no authors], 1970a'
    end

    it "One author" do
      reference = create :article_reference,
        author_names: [bolton],
        citation_year: '1970a'
      expect(reference.decorate.keey).to eq 'Bolton, 1970a'
    end

    it "Two authors" do
      reference = create :article_reference,
        author_names: [bolton, fisher],
        citation_year: '1970a'
      expect(reference.decorate.keey).to eq 'Bolton & Fisher, 1970a'
    end

    it "Three authors" do
      reference = create :article_reference,
        author_names: [bolton, fisher, ward],
        citation_year: '1970a'
      expect(reference.decorate.keey).to eq 'Bolton, Fisher & Ward, 1970a'
    end
  end

  describe "#inline_citation" do
    let(:latreille) { create :author_name, name: 'Latreille, P. A.' }
    before do
      science = create :journal, name: 'Science'
      @reference = create :article_reference,
        author_names: [latreille],
        citation_year: '1809',
        title: "*Atta*",
        journal: science,
        series_volume_issue: '(1)',
        pagination: '3'
      allow(@reference).to receive(:url).and_return 'example.com'
    end

    it "creates a link to the reference" do
      allow(@reference).to receive(:downloadable?).and_return true
      expect(@reference.decorate.inline_citation).to eq(
        %{<span class="reference_keey_and_expansion">} +
          %{<a class="reference_keey" title="Latreille, P. A. 1809. Atta. Science (1):3." href="#">Latreille, 1809</a>} +
          %{<span class="reference_keey_expansion">} +
            %{<span class="reference_keey_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span>} +
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
      expect(@reference.decorate.inline_citation).to eq(
        %{<span class="reference_keey_and_expansion">} +
          %{<a class="reference_keey" title="Latreille, P. A. 1809. Atta. Science (1):3." href="#">Latreille, 1809</a>} +
          %{<span class="reference_keey_expansion">} +
            %{<span class="reference_keey_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span> } +
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
          expect(@reference.decorate.antweb_version_of_inline_citation).to eq(
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
          expect(@reference.decorate.antweb_version_of_inline_citation).to eq(
            %{<a target="_blank" title="Latreille, P. A. 1809. Atta. Science (1):3." } +
            %{href="http://antcat.org/references/#{@reference.id}">Latreille, 1809</a>} +
            %{ <a class="document_link" target="_blank" href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a>} +
            %{ <a class="document_link" target="_blank" href="example.com">PDF</a>}
          )
        end
      end
    end

    describe "Handling quotes in the title" do
      let(:reference) do
        create :unknown_reference, author_names: [latreille],
          citation_year: '1809', title: '"Atta"'
      end

      it "escapes them" do
        expect(reference.decorate.antweb_version_of_inline_citation).to eq(
          %{<a target="_blank" title="Latreille, P. A. 1809. "Atta". New York." href="http://antcat.org/references/#{reference.id}">Latreille, 1809</a>}
        )
      end
    end
  end
end
