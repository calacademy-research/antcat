# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
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

      Taxon.count.should == 2

      tribe = Tribe.find_by_name 'Aneuretini'
      tribe.subfamily.name.should == 'Aneuretinae'
      tribe.taxonomic_history_items.map(&:taxt).should == ["Aneuretini history"]
      tribe.type_taxon_name.should == 'Aneuretus'
      tribe.type_taxon_rank.should == 'genus'
    end

    it "should import the junior synonym of a tribe" do
      emery = Factory :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>Aneuretini history</p>

        <p>Junior synonyms of ANEURETINI</p>
        <p>Paleosminthuridae Donisthorpe, 1947c: 588. Type-genus: <i>Anonychomyrma</i>.</p>
        <p>Taxonomic history</p>
        <p>Paleosminthuridae as tribe of Dolichoderinae: Donisthorpe, 1947c: 588.</p>
      }

      Taxon.count.should == 3

      senior_synonym = Tribe.find_by_name 'Aneuretini'
      junior_synonym = Tribe.find_by_name 'Paleosminthuridae'
      junior_synonym.should be_synonym
      junior_synonym.should be_synonym_of senior_synonym
      junior_synonym.subfamily.should == senior_synonym.subfamily
    end
  end
end
