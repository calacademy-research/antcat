require 'spec_helper'

describe Exporters::Antweb::Exporter do
  let(:formatter) { Exporters::Antweb::Exporter }

  describe "Taxon" do
    it "works" do
      formatter.new.send :export_history, create_genus
    end
  end

  describe "formatting a genus" do
    it "works" do
      bolton = create :author
      author_name = create :author_name, name: 'Bolton, B.', author: bolton
      journal = create :journal, name: 'Psyche'
      reference = ArticleReference.new author_names: [author_name],
        title: 'Ants I have known', citation_year: '2010a',
        journal: journal, series_volume_issue: '1', pagination: '2'
      authorship = Citation.create! reference: reference, pages: '12'
      name = create :genus_name, name: 'Atta'
      protonym = Protonym.create! name: name, authorship: authorship
      genus = create_genus name: name, protonym: protonym
      species = create_species 'Atta major', genus: genus

      # hol_id
      species.hol_id = 1234
      species.save!
      genus.hol_id = 1235
      genus.save!

      genus.update_attribute :type_name, species.name
      item = genus.history_items.create taxt: "Taxon: {tax #{species.id}} Name: {nam #{species.name.id}}"

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

      expect(formatter.new.send(:export_history, genus)).to eq(
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
              %{<a target="_blank" title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." href="http://antcat.org/references/#{reference.id}">Bolton, 2010a</a>} +
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
            %{<a class="link_to_external_site" target="_blank" href="http://hol.osu.edu/index.html?id=1235">HOL</a>} +

          %{</div>} +

          # taxonomic history
          %{<p><b>Taxonomic history</b></p>} +
          %{<div class="history"><div class="history_item" data-id="#{item.id}">} +
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
