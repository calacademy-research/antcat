# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do

    before do
      FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Latreille, I.')], :citation_year => '1809', :title => 'Ants', :bolton_key_cache => 'Latreille 1809'
      Family.import( 
        :protonym => {
          :family_or_subfamily_name => "Formicariae",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_genus => {:genus_name => 'Formica'},
        :history => ['Taxonomic history']
      )
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
      emery = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>Aneuretini history</p>
      }

      Taxon.count.should == 3

      tribe = Tribe.find_by_name 'Aneuretini'
      tribe.subfamily.name.to_s.should == 'Aneuretinae'
      tribe.history_items.map(&:taxt).should == ["{nam #{Name.find_by_name('Aneuretini').id}} history"]
      tribe.type_name.to_s.should == 'Aneuretus'
      tribe.type_name.rank.should == 'genus'
    end

    it "should import the junior synonym of a tribe" do
      emery = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
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

      Taxon.count.should == 4

      senior_synonym = Tribe.find_by_name 'Aneuretini'
      junior_synonym = Tribe.find_by_name 'Paleosminthuridae'
      junior_synonym.should be_synonym
      junior_synonym.should be_synonym_of senior_synonym
      junior_synonym.subfamily.should == senior_synonym.subfamily
    end

    #it "should import an ichnotaxon" do
      #FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
      #FactoryGirl.create :article_reference, bolton_key_cache: 'Laza 1982'
      #@importer.import_html make_contents %{
        #<p>Tribe ATTINI</P>
        #<p>Attini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>

        #<p>Ichnotaxon attached to Attini</p>
        #<p>Ichnogenus *<i>ATTAICHNUS</i></p>
        #<p>*<i>Attaichnus</i> Laza, 1982: 112. Included ichnospecies: *<i>Attaichnus kuenzelii</i>. [Ichnofossil, purportedly fossil traces of workings attributable
#to attine ants.]</p>
      #}
      #attaichnus = Genus.find_by_name 'Attaichnus'
      #attaichnus.should be_ichnotaxon
      #attaichnus.tribe.name.to_s.should == 'Attini'
      #attaichnus.subfamily.should == attaichnus.tribe.subfamily
    #end

  end
end
