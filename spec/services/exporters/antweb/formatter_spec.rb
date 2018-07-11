# TODO rename
#   `exporter_spec.rb` --> `exporter_export_taxon_spec.rb`
#   this file          --> `exporter_spec.rb`

# Specs here test stuff except `#export_taxon`, which is tested in another file
# because reasons and because both specs are pretty long.

require 'spec_helper'

describe Exporters::Antweb::Exporter do
  subject(:exporter) { described_class.new }

  describe "#header" do
    it "should be the same as the code" do
      expected = "antcat id\t" +
                 "subfamily\t" +
                 "tribe\t" +
                 "genus\t" +
                 "subgenus\t" +
                 "species\t" +
                 "subspecies\t" +
                 "author date\t" +
                 "author date html\t" +
                 "authors\t" +
                 "year\t" +
                 "status\t" +
                 "available\t" +
                 "current valid name\t" +
                 "original combination\t" +
                 "was original combination\t" +
                 "fossil\t" +
                 "taxonomic history html\t" +
                 "reference id\t" +
                 "bioregion\t" +
                 "country\t" +
                 "current valid rank\t" +
                 "hol id\t" +
                 "current valid parent"
      expect(exporter.send :header).to eq expected
    end
  end

  describe "#author_last_names_string" do
    context "when there is a protonym" do
      let(:genus) { build_stubbed :genus }

      it "delegates" do
        expect_any_instance_of(Reference)
          .to receive(:authors_for_keey).and_return 'Bolton'

        expect(exporter.send :author_last_names_string, genus).to eq 'Bolton'
      end
    end

    context "there is no protonym" do
      let(:genus) { build_stubbed :genus, protonym: nil }

      it "handles it" do
        expect(exporter.send :author_last_names_string, genus).to be_nil
      end
    end
  end

  describe "#original_combination" do
    context "when there was no recombining" do
      let!(:genus) { build_stubbed :genus }

      it "is nil" do
        expect(exporter.send :original_combination, genus).to be_nil
      end
    end

    context "when there has been some recombining" do
      let!(:original_combination) { create_species 'Atta major' }
      let!(:recombination) { create_species 'Eciton major' }

      before do
        original_combination.status = Status::ORIGINAL_COMBINATION
        original_combination.current_valid_taxon = recombination
        recombination.protonym.name = original_combination.name
        original_combination.save!
        recombination.save!
      end

      it "is the protonym" do
        expect(exporter.send :original_combination, recombination).to eq original_combination
      end
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
      context "when missing protonyms" do
        let!(:taxon) { build_stubbed :genus, protonym: nil }

        specify do
          expect(taxon.protonym).to be nil
          expect(exporter.send :authorship_html_string, taxon).to be nil
        end
      end

      context "when missing protonym authorships" do
        let!(:protonym) { build_stubbed :protonym, authorship: nil }
        let!(:taxon) { build_stubbed :genus, protonym: protonym }

        specify do
          expect(taxon.protonym).to_not be nil
          expect(exporter.send :authorship_html_string, taxon).to be nil
        end
      end

      context "when missing authorship references" do
        let!(:protonym) do
          build_stubbed :protonym, authorship: build_stubbed(:citation, reference: nil)
        end
        let!(:taxon) { build_stubbed :genus, protonym: protonym }

        specify do
          expect(taxon.protonym.authorship).to_not be nil
          expect(exporter.send :authorship_html_string, taxon).to be nil
        end
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

        # Genus and species.
        @genus = create_genus name: shared_name, protonym: protonym, hol_id: 9999
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
              %{<p>1 species</p>} +
            %{</div>} +

            # headline
            %{<div class="headline">} +
              # protonym
              %{<b><span><i>Atta</i></span></b> } +

              # authorship
              %{<span>} +
                %{<a title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." href="http://antcat.org/references/#{should_see_this_reference_id}">Bolton, 2010a</a>} +
                %{: 12} +
              %{</span>} +
              %{. } +

              # type
              %{<span>Type-species: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a>.</span>} +
              %{ } +
              # links
              %{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>} +
              %{ } +
              %{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Atta">AntWiki</a>} +
              %{ } +
              %{<a class="link_to_external_site" href="http://hol.osu.edu/index.html?id=9999">HOL</a>} +

            %{</div>} +

            # taxonomic history
            %{<p><b>Taxonomic history</b></p>} +
            %{<div class="history"><div class="history_item">} +
              %{<table><tr><td class="history_item_body" style="font-size: 13px">} +
                %{Taxon: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a> Name: <i>Atta major</i>.} +
              %{</td></tr></table>} +
            %{</div></div>} +

            # references
            %{<div class="reference_sections">} +
              %{<div class="section">} +
                %{<div class="title_taxt">Subfamily and tribe } +
                  %{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{a_tribe.id}">} +
                    %{#{a_tribe.name_cache}} +
                  %{</a>} +
                %{</div>} +
                %{<div class="references_taxt">} +
                  %{<a title="#{ref_author}, B.L. #{ref_year}. #{ref_title}. #{ref_journal_name} #{ref_volume}:#{ref_pagination}." href="http://antcat.org/references/#{a_reference.id}">} +
                    %{#{ref_author}, #{ref_year}} +
                  %{</a> } +
                  %{<a href="http://dx.doi.org/10.10.1038/nphys1170">} +
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

    it "handles italics in missing references (regression)" do
      # TODO
      # Confirm that `Exporters::Antweb::InlineCitation`
      # doesn't return "Brady, Schultz, &lt;i&gt;et al.&lt;/i&gt; 2006",
      # which happens with missing references unless we call "html_safe"
      # on this line: `link = helpers.link_to reference.keey.html_safe,`.
    end
  end

  describe "linking taxa on AntCat" do
    let(:taxon) { build_stubbed :family }

    describe ".antcat_taxon_link" do
      let(:link) { exporter.class.antcat_taxon_link taxon }

      it "includes 'antcat.org' in the url" do
        expect(link).to match "antcat.org"
      end

      it "uses 'AntCat' for the label" do
        expect(link).to match "AntCat</a>"
      end
    end

    describe ".antcat_taxon_link" do
      let(:link) { exporter.class.antcat_taxon_link_with_name taxon }

      it "includes 'antcat.org' in the url" do
        expect(link).to eq <<-HTML.squish
          <a class="link_to_external_site"
          href="http://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
        HTML
      end

      it "is html_safe" do
        expect(link).to be_html_safe
      end
    end
  end
end
