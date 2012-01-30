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
    %{<html><body><div><p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>
      <p>SUBFAMILY ANEURETINAE</p>
      <p>Subfamily ANEURETINAE </p>
      <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
      <p>Taxonomic history</p>
      <p>History</p>
      #{content}
      </div></body></html>}
    end

    it "should import a tribe" do
      emery = Factory :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>Aneuretini history</p>
      }

      Taxon.count.should == 3

      tribe = Tribe.find_by_name 'Aneuretini'
      tribe.subfamily.name.should == 'Aneuretinae'
      tribe.taxonomic_history_items.map(&:taxt).should == ["Aneuretini history"]
      tribe.type_taxon_name.should == 'Aneuretus'

      type_taxon = tribe.type_taxon
      type_taxon.name.should == 'Aneuretus'
      type_taxon.subfamily.should == tribe.subfamily
      type_taxon.tribe.should == tribe
    end

    it "should import the junior synonym of a tribe" do
      emery = Factory :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>Aneuretini history</p>

        <p>Junior synonyms of ANEURETINI</p>
        <p>Anonychomyrmini Donisthorpe, 1947c: 588. Type-genus: <i>Anonychomyrma</i>.</p>
        <p>Taxonomic history</p>
        <p>Anonychomyrmini as tribe of Dolichoderinae: Donisthorpe, 1947c: 588.</p>
      }

      Taxon.count.should == 12

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
        "Aneuretinae as junior synonym of Dolichoderinae: {ref #{MissingReference.first.id}}: 147"
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

    end
  end
end
