# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing a genus" do
    def make_contents content
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Martialinae' }
%{<html><body><div class=Section1>
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND
DOLICHODERINAE<o:p></o:p></span></b></p>
<p><b><span lang=EN-GB style='color:black'>SUBFAMILY</span><span lang=EN-GB> <span style='color:red'>MARTIALINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>MARTIALINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Martialinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus of Martialinae</span></b><span lang=EN-GB>: <i>Sphinctomyrmex</i>.</span></p>
<p><b><span lang=EN-GB>Genus of <span style='color:red'>Martialinae</span><o:p></o:p></span></b></p>
#{content}
</div></body></html>}
    end

    describe "Importing a genus with junior synonyms" do

      it "should not include the genus's references at the end of a junior synonym's taxonomic history" do
        @importer.import_html make_contents %{
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>SPHINCTOMYRMEX</span></i><o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Sphinctomyrmex</span></i></b><span lang=EN-GB> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p>Sphinctomyrmex history</p>
<p><b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>SPHINCTOMYRMEX<o:p></o:p></span></i></span></b></p>

<p><b><i><span lang=EN-GB>Aethiopopone</span></i></b><span lang=EN-GB> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p><i><span lang=EN-GB>Aethiopopone history</span></i></p>
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>Sphinctomyrmex</span></i> references <o:p></o:p></span></b></p>
<p>Sphinctomyrmex references</p>
        }

        sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        sphinctomyrmex.should_not be_nil
        sphinctomyrmex.taxonomic_history.should ==
%{<p><b><i>Sphinctomyrmex</i></b> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>} +
%{<p><b>Taxonomic history<p></p></b></p>} +
%{<p>Sphinctomyrmex history</p>} +
%{<p><b>Junior synonyms of <i>SPHINCTOMYRMEX<p></p></i></b></p>} +
%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
%{<p><b>Taxonomic history<p></p></b></p>} +
%{<p><i>Aethiopopone history</i></p>} +
%{<p><b>Genus <i>Sphinctomyrmex</i> references <p></p></b></p>} +
%{<p>Sphinctomyrmex references</p>}

        aethiopopone = Genus.find_by_name 'Aethiopopone'
        aethiopopone.should_not be_nil
        aethiopopone.should be_synonym_of sphinctomyrmex
        aethiopopone.taxonomic_history.should == 
%{<p><b><i>Aethiopopone</i></b> Santschi, 1930a: 49. Type-species: <i>Sphinctomyrmex rufiventris</i>, by monotypy. </p>} +
%{<p><b>Taxonomic history<p></p></b></p>} +
%{<p><i>Aethiopopone history</i></p>}
      end

    end

    describe "Importing a genus that replaced a homonym" do

      it "should save the homonym" do
        @importer.import_html make_contents %{
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>SPHINCTOMYRMEX</span></i><o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Sphinctomyrmex</span></i></b><span lang=EN-GB> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p>Sphinctomyrmex history</p>

<p><b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>SPHINCTOMYRMEX</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><b><i><span lang=EN-GB>Acrostigma</span></i></b><span lang=EN-GB> Forel, 1902h: 477 [as subgenus of <i>Acantholepis</i>].  Type-species: <i>Acantholepis (Acrostigma) froggatti</i>, by subsequent designation of Wheeler, W.M. 1911f: 158. </span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p><span lang=EN-GB>[Junior homonym of *<i>Acrostigma</i> Emery, 1891a: 149 (Formicidae).]</span></p>
        }

        sphinctomyrmex = Genus.find_by_name 'Sphinctomyrmex'
        sphinctomyrmex.should_not be_nil
        sphinctomyrmex.taxonomic_history.should ==
%{<p><b><i>Sphinctomyrmex</i></b> Mayr, 1866b: 895. Type-species: <i>Sphinctomyrmex stali</i>, by monotypy. </p>} +
%{<p><b>Taxonomic history<p></p></b></p>} +
%{<p>Sphinctomyrmex history</p>} 
        acrostigma = Genus.find_by_name 'Acrostigma'
        acrostigma.should_not be_nil
        acrostigma.should be_homonym_replaced_by sphinctomyrmex
      end

    end
  end
end
