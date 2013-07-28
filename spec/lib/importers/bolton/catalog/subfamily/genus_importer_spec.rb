# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing a genus" do
    def make_contents content
      @importer.stub :parse_family

      %{<html><body><div>
      <p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>
      <p>SUBFAMILY MARTIALINAE</p>
      <p>Subfamily MARTIALINAE</p>
      <p>Martialinae Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>
      <p>Genus of Martialinae<span lang=EN-GB>: <i>Sphinctomyrmex</i>.</span></p>
      <p>Genus of Martialinae</p>
      #{content}
      </div></body></html>}
    end

    it "should work" do
      latreille = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      lund = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Lund 1831a'
      swainson = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Swainson Shuckard 1840'
      baroni = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Baroni Urbani 1977c'

      @importer.import_html make_contents %{
        <p>Genus <i>CONDYLODON</i></p>
        <p><i>Condylodon</i> Lund, 1831a: 131. Type-species: <i>Condylodon audouini</i>, by monotypy. </p>
        <p>Taxonomic history</p>
        <p><i>Condylodon</i> in family Mutillidae: Swainson &amp; Shuckard, 1840: 173. </p>
        <p>Genus references</p>
        <p>Baroni Urbani, 1977c: 482 (review of genus).</p>
      }
      genus = Genus.find_by_name 'Condylodon'
      genus.should_not be_invalid
      genus.should_not be_fossil
      genus.subfamily.name.to_s.should == 'Martialinae'
      genus.history_items.map(&:taxt).should =~
        ["{nam #{Name.find_by_name('Condylodon').id}} in family {nam #{Name.find_by_name('Mutillidae').id}}: {ref #{swainson.id}}: 173."]
      genus.type_name.to_s.should == "Condylodon audouini"
      genus.type_taxt.should == ", by monotypy."
      genus.type_name.rank.should == 'species'
      genus.reference_sections.map(&:title_taxt).should == ['Genus references']
      genus.reference_sections.map(&:references_taxt).should == ["{ref #{baroni.id}}: 482 (review of genus)."]

      protonym = genus.protonym
      protonym.name.to_s.should == 'Condylodon'
      protonym.name.rank.should == 'genus'
      protonym.authorship.reference.should == lund
      protonym.authorship.pages.should == '131'
    end

    describe "Importing a genus that replaced a homonym" do
      it "should work" do
        @importer.import_html make_contents %{
          <p>Genus <i>SPHINCTOMYRMEX</i></p>
          <p><i>Sphinctomyrmex</i> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy.</p>
          <p>Taxonomic history</p>
          <p>Sphinctomyrmex history</p>

          <p>Homonym replaced by <i>SPHINCTOMYRMEX</i></p>
          <p><i>Acrostigma</i> Forel, 1902h: 477 [as subgenus of <i>Acantholepis</i>].  Type-species: <i>Acantholepis (Acrostigma) froggatti</i>, by subsequent designation of Wheeler, W.M. 1911f: 158.</p>
          <p>Taxonomic history</p>
          <p>[Junior homonym of *<i>Acrostigma</i> Emery, 1891a: 149 (Formicidae).]</p>
        }

        sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        sphinctomyrmex.should_not be_nil
        acrostigma = Genus.find_by_name 'Acrostigma'
        acrostigma.should_not be_nil
        acrostigma.should be_homonym_replaced_by sphinctomyrmex
      end
    end

    describe "Importing a genus followed by its synonym followed by a subgenus of the first one (not the synonym)" do
      it "should work" do
        @importer.import_html make_contents %{
          <p>Genus <i>LASIUS</i></p>
          <p><i>Lasius</i> Fabricius, 1804: 415. Type-species: <i>Formica nigra</i>, by subsequent designation of Bingham, 1903: 338.</p>
          <p>Taxonomic history</p>
          <p>Lasius history</p>

          <p>Junior synonyms of <i>LASIUS</i></p>
          <p>*<i>Tylolasius</i> Zhang, 1989: 295. Type-species: *<i>Tylolasius inflatus</i>, by original designation.</p>
          <p>Taxonomic history</p>
          <p>Tylolasius taxonomic history<i>Acrostigma</i> Emery, 1891a: 149 (Formicidae).]</p>

          <p>Subgenera of <i>LASIUS</i> include the nominal plus the following.</p>

          <p>Subgenus <i>LASIUS (ACANTHOMYOPS)</i></p>
          <p><i>Acanthomyops</i> Mayr, 1862: 652 (diagnosis in key), 699. Type-species: <i>Formica clavigera</i>, by monotypy.</p>
          <p>Taxonomic history</p>
          <p>Acanthomyops taxonomic history</p>
        }
        acanthomyops = Taxon.find_by_epithet('Acanthomyops').first
        lasius = Genus.find_by_name 'Lasius'
        acanthomyops.genus.should == lasius
        tylolasius = Genus.find_by_name 'Tylolasius'
        lasius.junior_synonyms.should == [tylolasius]
        tylolasius.senior_synonyms.should == [lasius]
      end

      it "should handle this second version of Ancylognathus" do
        @importer.import_html make_contents %{
          <p>Genus <i>ANCYLOGNATHUS</i></p>
          <p><i>Ancylognathus</i> Fabricius, 1804: 415.</p>

          <p>Genus <i>ECITON</i></p>
          <p><i>Eciton</i> Fabricius, 1804: 415.</p>

          <p>Junior synonyms of <i>ECITON</i></p>
          <p><i>Ancylognathus</i> Lund, 1831a: 121, 135. Type-species: <i>Ancylognathus lugubris</i>, <i>nomen nudum</i>.</p>
          <p><i>Camptognatha</i> Gray, G.R. 1832: 516.  Type-species: <i>Camptognatha testacea</i>, by monotypy. </p>
        }
      end

    end

    describe "Importing a genus with junior synonyms" do
      it "should not include the genus's references at the end of a junior synonym's taxonomic history" do
        bolton = FactoryGirl.create :article_reference, :bolton_key_cache => 'Bolton 1995b'
        @importer.import_html make_contents %{
          <p>Genus <i>SPHINCTOMYRMEX</i></p>
          <p><i>Sphinctomyrmex</i> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>
          <p>Taxonomic history</p>
          <p>Sphinctomyrmex history</p>

          <p>Junior synonyms of <i>SPHINCTOMYRMEX</i></p>

          <p><i>Aethiopopone</i> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>
          <p>Taxonomic history</p>
          <p><i>Aethiopopone</i> history</p>

          <p><b>Genus <i>Sphinctomyrmex</i> references</b></p>
          <p>[Note. Entries prior to Bolton, 1995b: 44, refer to genus as <i>Acantholepis</i>.]</p>
          <p><i>Sphinctomyrmex</i> references</p>
        }
        sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        sphinctomyrmex.history_items.map(&:taxt).should == ['Sphinctomyrmex history']
        sphinctomyrmex.reference_sections.map(&:references_taxt).should == [
          "[Note. Entries prior to {ref #{bolton.id}}: 44, refer to genus as {nam #{Name.find_by_name('Acantholepis').id}}.]",
          "{tax #{sphinctomyrmex.id}} references",
        ]
        aethiopopone = Genus.find_by_name 'Aethiopopone'
        aethiopopone.history_items.map(&:taxt).should == ["{nam #{aethiopopone.name.id}} history"]
        aethiopopone.reference_sections.should == []
      end
    end

  end

  describe "Parsing taxonomic history" do
    it "should return an array of text items converted to Taxt" do
      dalla_torre = FactoryGirl.create :article_reference, :bolton_key_cache => 'Dalla Torre 1893'
      swainson = FactoryGirl.create :article_reference, :bolton_key_cache => 'Swainson Shuckard 1840'
      @importer.initialize_parse_html %{<div>
        <p>Taxonomic history</p>
        <p><i>Condylodon</i> in family Mutillidae: Swainson &amp; Shuckard, 1840: 173.</p>
        <p><i>Condylodon</i> as junior synonym of <i>Pseudomyrma</i>: Dalla Torre, 1893: 55.</p>
      </div>}
      @importer.parse_history.should == [
        "{nam #{Name.find_by_name('Condylodon').id}} in family {nam #{Name.find_by_name('Mutillidae').id}}: {ref #{swainson.id}}: 173.",
        "{nam #{Name.find_by_name('Condylodon').id}} as junior synonym of {nam #{Name.find_by_name('Pseudomyrma').id}}: {ref #{dalla_torre.id}}: 55."
      ]
    end
    it "should handle the special case of Ponerites, which looks like a genus_headline" do
      dlussky = FactoryGirl.create :article_reference, :bolton_key_cache => 'Dlussky 1981b'
      @importer.initialize_parse_html %{<div>
        <p>Taxonomic history</p>
        <p><i>Ponerites</i> Dlussky, 1981b: 67 [collective group name].</p>
      </div>}
      @importer.parse_history.should == [
        "{nam #{Name.find_by_name('Ponerites').id}} {ref #{dlussky.id}}: 67 [collective group name]."
      ]
    end
  end

  describe "Parsing references" do

    it "should return an array of text items converted to Taxt" do
      genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Lepisiota')
      @importer.initialize_parse_html %{<div>
        <p>Genus <i>Lepisiota</i> references</p>
        <p>Note</p>
        <p>Another note</p>
      </div>}
      @importer.parse_genus_references genus
      genus.reference_sections.map(&:title_taxt).should ==
        ["Genus {tax #{genus.id}} references", ""]
      genus.reference_sections.map(&:references_taxt).should == ["Note", "Another note"]
    end

    describe "Genus reference sections with abbreviated genus names" do
      it "should handle this genus reference section with a subgenus name with abbreviated genus" do
        genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Dolichoderus')
        @importer.initialize_parse_html %{<div>
          <p>Genus <i>Dolichoderus</i> references</p>
          <p>Key <i>D. (Dolichoderus)</i></p>
        </div>}
        @importer.parse_genus_references genus
        Name.find_by_name('Dolichoderus (Dolichoderus)').should_not be_nil
      end
      it "should handle this genus reference section with a species name with abbreviated genus" do
        genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Dolichoderus')
        @importer.initialize_parse_html %{<div>
          <p>Genus <i>Dolichoderus</i> references</p>
          <p>Key <i>D. cuspidatus</i></p>
        </div>}
        @importer.parse_genus_references genus
        Name.find_by_name('Dolichoderus cuspidatus').should_not be_nil
      end
    end

  end
end
