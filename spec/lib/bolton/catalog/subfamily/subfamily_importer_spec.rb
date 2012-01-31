# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do

    before do
      Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, I.')], :citation_year => '1809', :title => 'Ants', :bolton_key_cache => 'Latreille 1809'
      Family.import( 
        :protonym => {
          :family_or_subfamily_name => "Formicariae",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_genus => {:genus_name => 'Formica'},
        :taxonomic_history => ['Taxonomic history']
      )
      ForwardReference.fixup
      @importer.stub :parse_family
    end

    def make_contents content
      %{<html><body><div><p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>#{content}</div></body></html>}
    end

    it "should import a subfamily" do
      emery = Factory :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>SUBFAMILY ANEURETINAE</p>
        <p>Subfamily ANEURETINAE </p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>

        <p>Taxonomic history</p>
        <p>Aneuretinae as junior synonym of Dolichoderinae: Baroni Urbani, 1989: 147.</p>

        <p>Tribes of Aneuretinae: Aneuretini, *Pityomyrmecini.</p>
        <p>Tribes <i>incertae sedis</i> in Aneuretinae: *Miomyrmecini.</p>
        <p>Genera (extinct) <i>incertae sedis</i> in Aneuretinae: *<i>Burmomyrma, *Cananeuretus</i>. </p>
        <p>Genus <i>incertae sedis</i> in Aneuretinae: <i>Wildensis</i>. </p>
        <p>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae: *<i>Curtipalpulus, *Eoleptocerites</i> (unresolved junior homonym).</p>

        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>history</p>

        <p>Junior synonyms of ANEURETINI</p>
        <p>Anonychomyrmini Donisthorpe, 1947c: 588. Type-genus: <i>Anonychomyrma</i>.</p>
        <p>Taxonomic history</p>
        <p>Anonychomyrmini as tribe of Dolichoderinae: Donisthorpe, 1947c: 588.</p>

        <p>Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references</p>
        <p>Emery, 1913a: 461 (diagnosis)</p>

        <p>Genera of Aneuretini</p>

        <p>Genus <i>ANEURETUS</i></p>
        <p><i>Aneuretus</i> Dlussky, 1988: 54. Type-species: *<i>Aneuretus deformis</i>, by original designation.</p>
        <p>Taxonomic history</p>
        <p>Aneuretus history</p>

        <p>Junior synonyms of <i>ANEURETUS</i></p>
        <p><i>Odontomyrmex</i> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>
        <p>Taxonomic history</p>
        <p>Odontomyrmex history</p>

        <p>Homonym replaced by <i>Odontomyrmex</i></p>
        <p><i>Diabolus</i> Roger, 1863a: 166. Type-species: <i>Diabolous nigella</i>, by monotypy. </p>
        <p>Taxonomic history</p>
        <p>Diabolous history</p>

        <p>Genus <i>Aneuretus</i> references</p>
        <p>Aneuretus reference</p>

        <p>Genera <i>incertae sedis</i> in ANEURETINAE</p>
        <p>Genus *<i>BURMOMYRMA</i></p>
        <p>*<i>Burmomyrma</i> Dlussky, 1996: 87. Type-species: *<i>Burmomyrma rossi</i>, by original designation.</p>
        <p>Taxonomic history</p>
        <p>History</p>

        <p>Genera of Hong (2002), <i>incertae sedis</i> in ANEURETINAE</p>
        <p>Genus *<i>WILSONIA</i></p>
        <p>*<i>Wilsonia</i> Hong, 2002: 608. Type-species: *<i>Wilsonia megagastrosa</i>, by original designation. </p>
        <p>Taxonomic history</p>
        <p>History</p>
      }

      Taxon.count.should == 14

      subfamily = Subfamily.find_by_name 'Aneuretinae'
      subfamily.should_not be_invalid
      subfamily.type_taxon_name.should == 'Aneuretus'

      protonym = subfamily.protonym
      protonym.name.should == 'Aneuretini'
      protonym.rank.should == 'tribe'

      authorship = protonym.authorship
      authorship.reference.should == emery
      authorship.pages.should == '6'

      type_taxon = subfamily.type_taxon
      type_taxon.name.should == 'Aneuretus'
      type_taxon.subfamily.should == subfamily

      subfamily.taxonomic_history_items.map(&:taxt).should =~ [
        "Aneuretinae as junior synonym of Dolichoderinae: {ref #{MissingReference.first.id}}: 147."
      ]

      tribe = Tribe.find_by_name 'Aneuretini'
      tribe.subfamily.should == subfamily
      tribe.taxonomic_history_items.map(&:taxt).should == ["history"]
      tribe.type_taxon_name.should == 'Aneuretus'
      tribe.reference_sections.map(&:title).should == ["Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references"]
      tribe.reference_sections.map(&:references).should == ["{ref #{emery.id}}: 461 (diagnosis)"]

      type_taxon = tribe.type_taxon
      type_taxon.name.should == 'Aneuretus'
      type_taxon.subfamily.should == subfamily
      type_taxon.tribe.should == tribe

      junior_synonym = Tribe.find_by_name 'Anonychomyrmini' 
      junior_synonym.synonym_of.should == tribe
      junior_synonym.should be_synonym

      aneuretus = Genus.find_by_name 'Aneuretus'
      aneuretus.tribe.should == tribe
      aneuretus.subfamily.should == subfamily
      aneuretus.reference_sections.map(&:references).should == ["Aneuretus reference"]

      junior_synonym = Genus.find_by_name 'Odontomyrmex'
      junior_synonym.synonym_of.should == aneuretus
      junior_synonym.should be_synonym
      junior_synonym.tribe.should == aneuretus.tribe
      junior_synonym.subfamily.should == aneuretus.subfamily

      homonym = Genus.find_by_name 'Diabolus'
      homonym.should be_homonym
      homonym.homonym_replaced_by.should == junior_synonym
      homonym.tribe.should == aneuretus.tribe
      homonym.subfamily.should == aneuretus.subfamily

      genus = Genus.find_by_name 'Burmomyrma'
      genus.should_not be_invalid
      genus.should be_fossil
      genus.tribe.should be_nil
      genus.incertae_sedis_in.should == 'subfamily'
      genus.subfamily.should == subfamily

      genus = Genus.find_by_name 'Wilsonia'
      genus.tribe.should be_nil
      genus.incertae_sedis_in.should == 'subfamily'
      genus.subfamily.should == subfamily
      genus.should be_hong
      genus.status.should == Status['unresolved homonym'].to_s

    end
  end
end
