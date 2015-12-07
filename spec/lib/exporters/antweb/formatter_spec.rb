# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Exporter do
  before do
    @formatter = Exporters::Antweb::Exporter
  end

  describe "Taxon" do
    it "should work" do
      @formatter.new.send(:export_history, create_genus)
    end
  end

  describe "formatting a genus" do
    it "should work" do
      bolton = FactoryGirl.create :author
      author_name = FactoryGirl.create :author_name, name: 'Bolton, B.', author: bolton
      journal = FactoryGirl.create :journal, name: 'Psyche'
      reference = ArticleReference.new author_names: [author_name], title: 'Ants I have known', citation_year: '2010a',
        journal: journal, series_volume_issue: '1', pagination: '2'
      authorship = Citation.create! reference: reference, pages: '12'
      name = FactoryGirl.create :genus_name, name: 'Atta'
      protonym = Protonym.create! name: name, authorship: authorship
      genus = create_genus name: name, protonym: protonym
      species = create_species 'Atta major', genus: genus
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: species.id, tnuid: 1234
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: genus.id, tnuid: 1235

      genus.update_attribute :type_name, species.name
      item = genus.history_items.create taxt: "Taxon: {tax #{species.id}} Name: {nam #{species.name.id}}"

      expect(@formatter.new.send(:export_history, genus)).to eq(
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
              %{<a href="http://antcat.org/references?q=#{reference.id}" target="_blank" title="Bolton, B. 2010a. Ants I have known. Psyche 1:2.">Bolton, 2010a</a>} +
              %{: 12} +
            %{</span>} +
            %{. } +

            # type
            %{<span class="type">Type-species: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}" target="_blank"><i>Atta major</i></a>.</span>} +
            %{ } +
            # links
            %{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}" target="_blank">AntCat</a>} +
            %{ } +
            %{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Atta" target="_blank">AntWiki</a>} +
            %{ } +
            %{<a class="link_to_external_site" href="http://hol.osu.edu/index.html?id=1235" target="_blank">HOL</a>} +

          %{</div>} +

          # taxonomic history
          %{<p><b>Taxonomic history</b></p>} +
          %{<div class="history"><div class="history_item item_#{item.id}" data-id="#{item.id}">} +
            %{<table><tr><td style="font-size: 13px" class="history_item_body">} +
              %{Taxon: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}" target="_blank"><i>Atta major</i></a> Name: <i>Atta major</i>.} +
            %{</td></tr></table>} +
          %{</div></div>} +

        %{</div>}
      )
    end
  end

end
