# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Formatter do
  before do
    @formatter = Exporters::Antweb::Formatter
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
      genus.update_attribute :type_name, species.name
      @formatter.new(genus).format.should ==
        %{<div class="antcat_taxon">} +
          %{<div class="statistics">} +
            %{<p class="taxon_statistics">1 species</p>} +
          %{</div>} +
          %{<div class="headline">} +
            %{<b><span class="genus name taxon"><i>Atta</i></span></b> } +
            %{<span class="authorship">} +
              %{<a href="http://antcat.org/references?q=#{reference.id}" target="_blank" title="Bolton, B. 2010a. Ants I have known. Psyche 1:2.">Bolton, 2010a</a>} +
              %{: 12} +
            %{</span>} +
            %{ } +
            %{<span class="type">Type-species: <span class="species taxon"><i>Atta major</i></span>.</span>} +
            %{ } +
            %{<a href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>} +
          %{</div>} +
        %{</div>}
    end
  end

end
