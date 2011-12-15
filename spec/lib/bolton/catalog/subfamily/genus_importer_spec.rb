# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Parsing taxonomic history" do
    it "should return an array of a single :text taxonomic history item" do
      @importer.initialize_parse_html %{<div>
        <p>Taxonomic history</p>
        <p><i>Condylodon</i> forgotten all about.</p>
      </div>}
      @importer.parse_genus_taxonomic_history.should ==
%{<p>Taxonomic history</p><p><i>Condylodon</i> forgotten all about.</p>}
      @importer.parsed_taxonomic_history.should == [
        {:type => :genus_taxonomic_history_item,
         :texts => [{
          :text=> [
            {:genus_name => "Condylodon", :delimiter => " "},
            {:phrase => "forgotten all about"}
          ]}]
        },
      ]
    end
    it "should return an array of taxonomic history items" do
      @importer.initialize_parse_html %{<div>
        <p>Taxonomic history</p>
        <p><i>Condylodon</i> in family Mutillidae?: Swainson &amp; Shuckard, 1840: 173.</p>
        <p><i>Condylodon</i> as junior synonym of <i>Pseudomyrma</i>: Dalla Torre, 1893: 55.</p>
      </div>}
      @importer.parse_genus_taxonomic_history.should ==
%{<p>Taxonomic history</p><p><i>Condylodon</i> in family Mutillidae?: Swainson & Shuckard, 1840: 173.</p><p><i>Condylodon</i> as junior synonym of <i>Pseudomyrma</i>: Dalla Torre, 1893: 55.</p>}
      @importer.parsed_taxonomic_history.should == [
        {:type => :genus_taxonomic_history_item,
         :genus => {:genus_name => 'Condylodon'},
         :in => [{:taxon => [{:family_or_subfamily_name => 'Mutillidae'}], :questionable => true}],
         :references => [{:author_names => ['Swainson', 'Shuckard'], :year => '1840', :pages => '173'}],
        },
        {:type => :genus_taxonomic_history_item,
         :genus => {:genus_name => 'Condylodon'},
         :as_junior_synonym_of => {:genus => {:genus_name => 'Pseudomyrma'}},
         :references => [{:author_names => ['Dalla Torre'], :year => '1893', :pages => '55'}],
        }
      ]
    end
  end

  describe "Importing a genus" do
    def make_contents content
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Martialinae' }
%{<html><body><div class=Section1>
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND
DOLICHODERINAE</span></b></p>
<p><b><span lang=EN-GB style='color:black'>SUBFAMILY</span><span lang=EN-GB> <span style='color:red'>MARTIALINAE</span></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>MARTIALINAE</span></span></b></p>
<p><b><span lang=EN-GB>Martialinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus of Martialinae</span></b><span lang=EN-GB>: <i>Sphinctomyrmex</i>.</span></p>
<p><b><span lang=EN-GB>Genus of <span style='color:red'>Martialinae</span></span></b></p>
#{content}
</div></body></html>}
    end

    describe "Importing a genus with junior synonyms" do

      it "should not include the genus's references at the end of a junior synonym's taxonomic history" do
        @importer.import_html make_contents %{
<p>Genus <i>SPHINCTOMYRMEX</i></p>
<p><i>Sphinctomyrmex</i> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p>Sphinctomyrmex history</p>

<p>Junior synonyms of <i>SPHINCTOMYRMEX</i></p>

<p><i>Aethiopopone</i> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p><i>Aethiopopone history</i></p>

<p><b>Genus <i>Sphinctomyrmex</i> references <p></p></b></p>
<p>[Note. Entries prior to Bolton, 1995b: 44, refer to genus as <i>Acantholepis</i>.]</p>
<p>Sphinctomyrmex references</p>
        }

        #sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        #sphinctomyrmex.should_not be_nil
        #sphinctomyrmex.taxonomic_history.should ==
#%{<p><b><i>Sphinctomyrmex</i></b> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p>Sphinctomyrmex history</p>} +
#%{<p><b>Junior synonyms of <i>SPHINCTOMYRMEX<p></p></i></b></p>} +
#%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p><i>Aethiopopone history</i></p>} +

        #aethiopopone = Genus.find_by_name 'Aethiopopone'
        #aethiopopone.should_not be_nil
        #aethiopopone.should be_synonym_of sphinctomyrmex
        #aethiopopone.taxonomic_history.should == 
#%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p><i>Aethiopopone history</i></p>}
      end

    end

    describe "Importing a subgenus" do

      it "should not include the genus's references at the end of a junior synonym's taxonomic history" do
        @importer.import_html make_contents %{
<p>Genus <i>SPHINCTOMYRMEX</i></p>
<p><i>Sphinctomyrmex</i> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p>Sphinctomyrmex history</p>

<p>Subgenera of <i>SPHINCTOMYRMEX</i> include the nominal plus the following.</p>

<p>Subgenus <i>LASIUS (SPHINCTOMYRMEX)</i></p>
<p><i>Acanthomyops</i> Mayr, 1862: 652 (diagnosis in key), 699. Type-species: <i>Formica clavigera</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p><i>Acanthomyops</i> in Formicinae: Mayr, 1862: 652 (in key) [Formicidae]; Mayr, 1865: 8 [Formicidae].</p>
        }

        #sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        #sphinctomyrmex.should_not be_nil
        #sphinctomyrmex.taxonomic_history.should ==
#%{<p><b><i>Sphinctomyrmex</i></b> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p>Sphinctomyrmex history</p>} +
#%{<p><b>Junior synonyms of <i>SPHINCTOMYRMEX<p></p></i></b></p>} +
#%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p><i>Aethiopopone history</i></p>} +
#%{<p><b>Genus <i>Sphinctomyrmex</i> references <p></p></b></p>} +
#%{<p>Sphinctomyrmex references</p>}

        #aethiopopone = Genus.find_by_name 'Aethiopopone'
        #aethiopopone.should_not be_nil
        #aethiopopone.should be_synonym_of sphinctomyrmex
        #aethiopopone.taxonomic_history.should == 
#%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p><i>Aethiopopone history</i></p>}
      end

    end

    describe "Importing a genus that replaced a homonym" do

      it "should save the homonym" do
        @importer.import_html make_contents %{
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>SPHINCTOMYRMEX</span></i></span></b></p>
<p><b><i><span lang=EN-GB>Sphinctomyrmex</span></i></b><span lang=EN-GB> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Taxonomic history</span></b></p>
<p>Sphinctomyrmex history</p>

<p><b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>SPHINCTOMYRMEX</span></i></span></b><span lang=EN-GB style='color:red'></span></p>
<p><span lang=EN-GB>&nbsp;</span></p>
<p><b><i><span lang=EN-GB>Acrostigma</span></i></b><span lang=EN-GB> Forel, 1902h: 477 [as subgenus of <i>Acantholepis</i>].  Type-species: <i>Acantholepis (Acrostigma) froggatti</i>, by subsequent designation of Wheeler, W.M. 1911f: 158. </span></p>
<p><b><span lang=EN-GB>Taxonomic history</span></b></p>
<p><span lang=EN-GB>[Junior homonym of *<i>Acrostigma</i> Emery, 1891a: 149 (Formicidae).]</span></p>
        }

        #sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        #sphinctomyrmex.should_not be_nil
        #sphinctomyrmex.taxonomic_history.should ==
#%{<p><b><i>Sphinctomyrmex</i></b> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p>Sphinctomyrmex history</p>} 
        #acrostigma = Genus.find_by_name 'Acrostigma'
        #acrostigma.should_not be_nil
        #acrostigma.should be_homonym_replaced_by sphinctomyrmex
      end

    end
  end
end
