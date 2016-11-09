require 'spec_helper'

describe Exporters::Antweb::Exporter do
  let(:exporter) { Exporters::Antweb::Exporter.new }

  describe "#author_last_names_string" do
    it "delegates" do
      genus = build_stubbed :genus
      expect_any_instance_of(ReferenceDecorator)
        .to receive(:authors_for_keey).and_return 'Bolton'

      expect(exporter.send :author_last_names_string, genus).to eq 'Bolton'
    end

    context "there is no protonym" do
      it "handles it" do
        genus = build_stubbed :genus, protonym: nil
        expect(exporter.send :author_last_names_string, genus).to be_nil
      end
    end
  end

  describe "#original_combination" do
    it "is nil if there was no recombining" do
      genus = build_stubbed :genus
      expect(exporter.send :original_combination, genus).to be_nil
    end

    it "is the protonym, otherwise" do
      original_combination = create_species 'Atta major'
      recombination = create_species 'Eciton major'
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!

      expect(exporter.send :original_combination, recombination).to eq original_combination
    end
  end

  describe "#authorship_html_string" do
    let(:taxon) { create_genus }
    let(:reference) do
      journal = create :journal, name: 'Ants'
      author_name = create :author_name, name: "Forel, A."
      create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
    end

    it "formats references into HTML, with rollover" do
      taxon.protonym.authorship.reference = reference
      expected = '<span title="Forel, A. 1874. Format. Ants 1:1:2.">Forel, 1874</span>'
      expect(exporter.send :authorship_html_string, taxon).to eq expected
    end

    context "something is missing" do
      it "handles missing protonyms" do
        taxon = build_stubbed :genus, protonym: nil
        expect(taxon.protonym).to be nil
        expect(exporter.send :authorship_html_string, taxon).to be nil
      end

      it "handles missing protonym authorships" do
        protonym = build_stubbed :protonym, authorship: nil
        taxon = build_stubbed :genus, protonym: protonym

        expect(taxon.protonym).to_not be nil
        expect(exporter.send :authorship_html_string, taxon).to be nil
      end

      it "handles missing authorship references" do
        authorship = build_stubbed :citation, reference: nil
        protonym = build_stubbed :protonym, authorship: authorship
        taxon = build_stubbed :genus, protonym: protonym

        expect(taxon.protonym.authorship).to_not be nil
        expect(exporter.send :authorship_html_string, taxon).to be nil
      end
    end
  end

  describe "#export_history" do
    it "doesn't blow up" do
      exporter.send :export_history, create_genus
    end

    context "a genus" do
      before do
        shared_name = create :genus_name, name: 'Atta'

        # Protonym.
        author_name = create :author_name,
          name: 'Bolton, B.',
          author: create(:author)
        reference = ArticleReference.new author_names: [author_name],
          title: 'Ants I have known',
          citation_year: '2010a',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1',
          pagination: '2'
        authorship = Citation.create! reference: reference, pages: '12'
        protonym = Protonym.create! name: shared_name, authorship: authorship

        # Genus.
        @genus = create_genus name: shared_name, protonym: protonym, hol_id: 9999

        # Species.
        @species = create_species 'Atta major', genus: @genus, hol_id: 1234
      end

      it "formats a taxon's history suitable for AntWeb" do
        species = @species
        genus = @genus

        should_see_this_reference_id = genus.protonym.authorship.reference.id

        genus.update_attribute :type_name, species.name
        history_item = genus.history_items.create taxt: "Taxon: {tax #{species.id}} Name: {nam #{species.name.id}}"

        # for TaxonDecorator#references
        a_reference = create :article_reference
        a_tribe = create :tribe
        a_reference_section = genus.reference_sections.create(
          title_taxt: "Subfamily and tribe {tax #{a_tribe.id}}",
          references_taxt: "{ref #{a_reference.id}}: 766 (diagnosis);")
        ref_author = a_reference.principal_author_last_name_cache
        ref_year = a_reference.citation_year
        ref_title = a_reference.title
        ref_journal_name = a_reference.journal.name
        ref_pagination = a_reference.pagination
        ref_volume = a_reference.series_volume_issue

        results = exporter.send :export_history, genus
        expect(results).to eq(
          %{<div class="antcat_taxon">} +

            # statistics
            %{<div class="statistics">} +
              %{<p class="taxon_statistics">1 species</p>} +
            %{</div>} +

            # headline
            %{<div class="headline">} +
              # protonym
              %{<b><span class="protonym_name"><i>Atta</i></span></b> } +

              # authorship
              %{<span class="authorship">} +
                %{<a target="_blank" title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." href="http://antcat.org/references/#{should_see_this_reference_id}">Bolton, 2010a</a>} +
                %{: 12} +
              %{</span>} +
              %{. } +

              # type
              %{<span class="type">Type-species: <a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a>.</span>} +
              %{ } +
              # links
              %{<a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>} +
              %{ } +
              %{<a class="link_to_external_site" target="_blank" href="http://www.antwiki.org/wiki/Atta">AntWiki</a>} +
              %{ } +
              %{<a class="link_to_external_site" target="_blank" href="http://hol.osu.edu/index.html?id=9999">HOL</a>} +

            %{</div>} +

            # taxonomic history
            %{<p><b>Taxonomic history</b></p>} +
            %{<div class="history"><div class="history_item" data-id="#{history_item.id}">} +
              %{<table><tr><td style="font-size: 13px" class="history_item_body">} +
                %{Taxon: <a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a> Name: <i>Atta major</i>.} +
              %{</td></tr></table>} +
            %{</div></div>} +

            # references
            %{<div class="reference_sections">} +
              %{<div class="section">} +
                %{<div class="title_taxt">Subfamily and tribe } +
                  %{<a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{a_tribe.id}">} +
                    %{#{a_tribe.name_cache}} +
                  %{</a>} +
                %{</div>} +
                %{<div class="references_taxt">} +
                  %{<a target="_blank" title="#{ref_author}, B.L. #{ref_year}. #{ref_title}. #{ref_journal_name} #{ref_volume}:#{ref_pagination}." href="http://antcat.org/references/#{a_reference.id}">} +
                    %{#{ref_author}, #{ref_year}} +
                  %{</a> } +
                  %{<a class="document_link" target="_blank" href="http://dx.doi.org/10.10.1038/nphys1170">} +
                    %{10.10.1038/nphys1170} +
                  %{</a>} +
                  %{: 766 (diagnosis);} +
                %{</div>} +
              %{</div>} +
            %{</div>} +

          %{</div>}
        )
      end
    end
  end

  describe "caching" do
    let(:reference) { create :article_reference }

    # Slightly stupid test case but just to be sure...
    it "doesn't use `references.inline_citation_cache`" do
      # Trigger inline_citation_cache, AntCat variant.
      ReferenceFormatterCache.populate reference
      expect(reference.inline_citation_cache).to_not include "antcat.org"

      # Make sure we're getting the AntWeb version. This actually hits
      # `references.formatted_cache` as opposed to `references.inline_citation`.
      antweb_version = reference.decorate.antweb_version_of_inline_citation
      expect(antweb_version).to include "antcat.org"
    end
  end
end
