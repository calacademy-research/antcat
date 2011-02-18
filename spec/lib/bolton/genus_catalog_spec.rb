require 'spec_helper'

describe Bolton::GenusCatalog do
  before do
    @genus_catalog = Bolton::GenusCatalog.new
  end

  describe "importing files" do
    it "should process them in alphabetical order (not counting extension), so the three Camponotus files get processed in the right order" do
      File.should_receive(:read).with('NGC-GEN.A-L.htm').ordered.and_return ''
      File.should_receive(:read).with('NGC-GEN.M-Z.htm').ordered.and_return ''
      @genus_catalog.import_files ['NGC-GEN.A-L.htm', 'NGC-GEN.M-Z.htm']
    end
  end

  describe 'importing html' do
    
    describe "processing a representative sample and making sure they're saved correctly" do
      it 'should work' do
        Progress.should_not_receive :error
        @genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:blue'>ALAOPONE</span></i></b> [subgenus of <i style='mso-bidi-font-style:
normal'>Acromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Acamatus</i> Emery, 1894c: 181 [as subgenus
of <i style='mso-bidi-font-style:normal'>Eciton</i>]. Type-species: <i
style='mso-bidi-font-style:normal'>Eciton (Acamatus) schmitti</i> (junior
synonym of <i style='mso-bidi-font-style:normal'>Labidus nigrescens</i>), by
subsequent designation of Ashmead, 1906: 24; Wheeler, W.M. 1911f: 157. [Junior
homonym of <i style='mso-bidi-font-style:normal'>Acamatus </i>Schoenherr, 1833:
20 (Coleoptera).] </p>

<p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
style='color:black'>ACALAMA</span></i> [junior synonym of <i style='mso-bidi-font-style:
normal'>Acromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i
style='mso-bidi-font-style:normal'>Acromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>ACAMATUS</i> [junior homonym, see <i
style='mso-bidi-font-style:normal'>Acromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'><span style='color:purple'>ANCYLOGNATHUS</span></i>
[<i style='mso-bidi-font-style:normal'>Nomen nudum</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>PROTAZTECA</span></i></b> [<i style='mso-bidi-font-style:
normal'>incertae sedis</i> in Dolichoderinae]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>MYANMYRMA</span></i></b> [<i style='mso-bidi-font-style:normal'>incertae
sedis</i> in Formicidae]</p>
        }

        Genus.count.should == 7
        Subgenus.count.should == 2

        acromyrmex = Genus.find_by_name 'Acromyrmex'
        acromyrmex.should_not be_fossil
        acromyrmex.subfamily.name.should == 'Myrmicinae'
        acromyrmex.tribe.name.should == 'Attini'
        acromyrmex.should_not be_invalid
        acromyrmex.taxonomic_history.should == %{<p class="MsoNormal" style="margin-left:.5in;text-align:justify;text-indent:-.5in"><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:red">ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>}
        acromyrmex.incertae_sedis_in.should be_nil

        alaopone = Subgenus.find_by_name 'Alaopone'
        alaopone.genus.name.should == 'Acromyrmex'
        alaopone.should_not be_fossil
        alaopone.should_not be_invalid

        acanothomyops = Subgenus.find_by_name 'Acanthomyops'
        acanothomyops.genus.name.should == 'Acromyrmex'

        attaichnus = Genus.find_by_name 'Attaichnus'
        attaichnus.should be_fossil
        attaichnus.should be_unidentifiable

        acalama = Genus.find_by_name 'Acalama'
        acalama.should_not be_fossil
        acalama.should be_synonym
        acalama.should be_invalid
        acalama.synonym_of.name.should == 'Acromyrmex'

        ancylognathus = Genus.find_by_name 'Ancylognathus'
        ancylognathus.should_not be_available
        
        protazteca = Genus.find_by_name 'Protazteca'
        protazteca.incertae_sedis_in.should == 'subfamily'
        protazteca.subfamily.name.should == 'Dolichoderinae'

        acamatus = Genus.find_by_name 'Acamatus'
        acamatus.should be_homonym
        acamatus.should be_invalid
        acamatus.homonym_resolved_to.name.should == 'Acromyrmex'

        myanmyrma = Genus.find_by_name 'Myanmyrma'
        myanmyrma.should be_valid
        myanmyrma.incertae_sedis_in.should == 'family'
      end
    end
    
    it "should add both homonyms" do
        @genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<i
style='mso-bidi-font-style:normal'>ACROSTIGMA </i>[junior synonym of <i
style='mso-bidi-font-style:normal'>Podomyrma</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<i
style='mso-bidi-font-style:normal'>Acrostigma</i> Emery, 1891a: 149 [as
subgenus of <i style='mso-bidi-font-style:normal'>Podomyrma</i>]. Type-species:
*<i style='mso-bidi-font-style:normal'>Podomyrma (Acrostigma) mayri</i>, by
monotypy. </p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<i
style='mso-bidi-font-style:normal'>Acrostigma </i>junior synonym of <i
style='mso-bidi-font-style:normal'>Podomyrma</i>: Dalla Torre, 1893: 159.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>ACROSTIGMA</i> [junior homonym, see <i
style='mso-bidi-font-style:normal'>Stigmacros</i>]</p>
        }
        Genus.count.should == 4

        acrostigma_synonym = Genus.find_by_name_and_status('Acrostigma', 'synonym')
        acrostigma_synonym.should_not be_nil
        acrostigma_synonym.synonym_of.name.should == 'Podomyrma'

        acrostigma_homonym = Genus.find_by_name_and_status('Acrostigma', 'homonym')
        acrostigma_homonym.should_not be_nil
        acrostigma_homonym.homonym_resolved_to.name.should == 'Stigmacros'
    end

    it "should silently swallow a collective group name" do
      Progress.should_not_receive :error
      @genus_catalog.import_html make_content %{*<i><span style="color:green">FORMICITES</span></i> [collective group name]}
    end

    describe "error handling" do
      it "should squawk when a genus header can't be parsed" do
        Progress.should_receive(:error).with("parse failed on: 'FOO'")
        @genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>PROTAZTECA</span></i></b> [<i style='mso-bidi-font-style:
normal'>incertae sedis</i> in Dolichoderinae]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>FOO</p>
        }
      end
    end

    it "should handle this especially weird case where one name is a homonym and two synonyms" do
      @genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>HOLCOPONERA</i> [junior synonym of <i
style='mso-bidi-font-style:normal'>Gnamptogenys</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Holcoponera </i>Mayr, 1887: 540 [as subgenus
of <i style='mso-bidi-font-style:normal'>Ectatomma</i>]. Type-species: <i
style='mso-bidi-font-style:normal'>Gnamptogenys striatula</i>, by subsequent
designation of Emery, 1911d: 40. </p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Holcoponera</i> raised to genus: Emery,
1902b: 181. </p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Holcoponera</i> junior synonym of <i
style='mso-bidi-font-style:normal'>Gnamptogenys</i>: Brown, 1958g: 211.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>HOLCOPONERA </i>[junior homonym, junior
synonym of <i style='mso-bidi-font-style:normal'>Cylindromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Holcoponera</i> Cameron, 1891: 92.
Type-species: <i style='mso-bidi-font-style:normal'>Holcoponera whymperi</i>,
by monotypy. [Unresolved junior homonym of <i style='mso-bidi-font-style:normal'>Holcoponera</i>
Mayr, 1887, above.] </p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>Holcoponera</i> Cameron junior synonym of <i
style='mso-bidi-font-style:normal'>Cylindromyrmex</i>: Forel, 1892f: 256.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
      }

      Genus.count.should == 4
    end

    def make_content content
      %{<html> <head> <title>CATALOGUE OF GENUS-GROUP TAXA</title> </head>
<body>
<div class=Section1>
<p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE OF
SPECIES-GROUP TAXA<o:p></o:p></b></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#{content}
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
</div> </body> </html>
    }
      end
  end

end
