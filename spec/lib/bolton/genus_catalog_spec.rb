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
        Factory :genus, :name => 'Acromyrmex'
        Factory :genus, :name => 'Protazteca'
        Factory :genus, :name => 'Myanmyrma'
        Factory :subfamily, :name => 'Myrmicinae'
        Factory :subfamily, :name => 'Dolichoderinae'
        Factory :tribe, :name => 'Attini'
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
        lll{'Genus.all.map(&:name)'}

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
    
    describe "Genera outside Formicidae" do
      it "should not set the subfamily of a genus to one that's not even in Formicidae" do
        Factory :subfamily, :name => 'Aculeata'
        @genus_catalog.import_html make_content %{
  <p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
  -36.0pt'>*<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:
  normal'><span style='color:green'>CARIRIDRIS</span></i></b> [<i
  style='mso-bidi-font-style:normal'>incertae sedis</i> in Aculeata]</p>

  <p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
  -36.0pt'>*<i style='mso-bidi-font-style:normal'>Cariridris</i> Brandão &amp;
  Martins-Neto, 1990: 201. Type-species: *<i style='mso-bidi-font-style:normal'>Cariridris
  bipetiolata</i>, by original designation. </p>

  <p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
  -36.0pt'>*<i style='mso-bidi-font-style:normal'>Cariridris</i> in Sphecidae:
  Verhaagh, 1996: 11; Dlussky &amp; Rasnitsyn, 2002: 418; <i style='mso-bidi-font-style:
  normal'>incertae sedis</i> in Aculeata: Grimaldi, Agosti &amp; Carpenter, 1997:
  7; Ward &amp; Brady, 2003: 362. <b style='mso-bidi-font-weight:normal'>Excluded
  from Formicidae</b>.</p>
        }
        cariridris = Genus.find_by_name 'Cariridris'
        cariridris.subfamily.should be_nil
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
        Factory :subfamily, :name => 'Dolichoderinae'
        Factory :genus, :name => 'Protazteca'
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

    it "should complain if the genus is brand new" do
      Factory :subfamily, :name => 'Myrmicinae'
      Factory :tribe, :name => 'Attini'
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>
      }}.should raise_error "Genus Acromyrmex not found"
    end

    it "should not complain if the genus is brand new but is a synonym" do
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
style='color:black'>ACALAMA</span></i> [junior synonym of <i style='mso-bidi-font-style:
normal'>Gauromyrmex</i>]</p>
      }}.should_not raise_error
      acalama = Genus.find_by_name 'Acalama'
      acalama.status.should == 'synonym'
    end

    it "should not complain if the genus is brand new but is a homonym" do
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><i style='mso-bidi-font-style:normal'>ACAMATUS</i> [junior homonym,
see <i style='mso-bidi-font-style:normal'>Neivamyrmex</i>]</p>
      }}.should_not raise_error
      acamatus = Genus.find_by_name 'Acamatus'
      acamatus.status.should == 'homonym'
    end

    it "should not complain if the genus is brand new but is unavailable" do
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><i style='mso-bidi-font-style:normal'><span style='color:purple'>ACHANTILEPIS</span>
</i>[<b style='mso-bidi-font-weight:normal'>unavailable name</b>]</p>
      }}.should_not raise_error
      achantilepis = Genus.find_by_name 'Achantilepis'
      achantilepis.status.should == 'unavailable'
    end

    it "should not complain if the genus is brand new but is unidentifiable" do
      Factory :subfamily, :name => 'Myrmicinae'
      Factory :tribe, :name => 'Attini'
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'>*<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:
normal'><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae:
Attini]</p>
      }}.should_not raise_error
      attaichnus = Genus.find_by_name 'Attaichnus'
      attaichnus.status.should == 'unidentifiable'
    end

    it "should not complain if the genus is brand new but is an unresolved homonym and synonym" do
      lambda {@genus_catalog.import_html make_content %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><i style='mso-bidi-font-style:normal'>MYRMEX</i> [junior homonym,
junior synonym of <i style='mso-bidi-font-style:normal'>Pseudomyrma</i>]</p>
      }}.should_not raise_error
      myrmex = Genus.find_by_name 'Myrmex'
      myrmex.status.should == 'unresolved_homonym_and_synonym'
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

  describe "Parsing lines" do

    it 'should handle a blank line' do
      @genus_catalog.parse("\n").should == :blank_line
    end

    it 'should handle complete garbage' do
      line = %{asdfj;jsdf}
      @genus_catalog.parse(line).should == {:type => :not_understood}
    end

    it 'should handle all sorts of guff within the tags' do
      line = %{<b
        style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
        style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
      @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :status => :valid}
    end

    describe 'Parsing the genus name' do
      it 'should parse a normal genus name' do
        line = %{<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                          :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :status => :valid}
      end

      it 'should handle an italic space' do
        line = %{<b><i><span style="color:red">PROTOMOGNATHUS</span></i></b><i> </i>[Myrmicinae: Formicoxenini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Protomognathus',
                                                          :subfamily => 'Myrmicinae', :tribe => 'Formicoxenini', :status => :valid}
      end

      it 'should parse a fossil genus name' do
        line = %{*<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                          :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :fossil => true, :status => :valid}
      end

      it 'should parse an unidentifiable genus name' do
        line = %{*<b><i><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Attaichnus', :status => :unidentifiable,
                                                          :subfamily => 'Myrmicinae', :tribe => 'Attini', :fossil => true}
      end

      it 'should handle parens instead of brackets' do
        line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini)}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acromyrmex', :status => :valid,
                                                          :subfamily => 'Myrmicinae', :tribe => 'Attini'}
      end

      it 'should handle paren at one end and bracket at the other' do
        line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acromyrmex', :status => :valid,
                                                          :subfamily => 'Myrmicinae', :tribe => 'Attini'}
      end

      it "should handle this spacing" do
        line = %{<b><i><span style="color:red">LEPISIOTA</span></i></b><span style="color: red"> </span>[Formicinae: Plagiolepidini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Lepisiota', :status => :valid,
                                                          :subfamily => 'Formicinae', :tribe => 'Plagiolepidini'}
      end


      describe "Unavailable names" do

        it "should recognize a nomen nudum" do
          line = %{<i><span style='color:purple'>ANCYLOGNATHUS</span></i> [<i>Nomen nudum</i>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Ancylognathus', :status => :unavailable}
        end

        it "should recognize an unavailable name" do
          line = %{<i><span style="color:purple">ACHANTILEPIS</span></i> [<b>unavailable name</b>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Achantilepis', :status => :unavailable}
        end

        it "should recognize an unavailable name with an italicized space" do
          line = %{<i><span style="color:purple">ACHANTILEPIS</span> </i>[<b>unavailable name</b>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Achantilepis', :status => :unavailable}
        end

        it "should handle when the bracketed remark at end has a trailing bracket in bold" do
          line = %{<i><span style="color:purple">MYRMECIUM</span></i> [<b>unavailable name]</b>}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Myrmecium', :status => :unavailable}
        end

      end
    end

    describe "Subgenus" do

      it "should recognize a subgenus" do
        line = %{#<b><i><span style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i>Lasius</i>]}
        @genus_catalog.parse(line).should == {:type => :subgenus, :name => 'Acanthomyops', :genus => 'Lasius', :status => :valid}
      end

      it "should ignore an errant blue space" do
        line = %{#<b><i><span style="color:blue">ANOMMA</span></i></b><span style="color:blue"> </span>[subgenus of <i>Dorylus</i>]}
        @genus_catalog.parse(line).should == {:type => :subgenus, :name => 'Anomma', :genus => 'Dorylus', :status => :valid}
      end

      it "should handle it when the # is in black" do
        line = %{<span style="color:black">#</span><b><i><span style="color:blue">BARONIURBANIA</span></i></b> [subgenus of <i>Lepisiota</i>]}
        @genus_catalog.parse(line).should == {:type => :subgenus, :name => 'Baroniurbania', :genus => 'Lepisiota', :status => :valid}
      end

      it "should handle it when it's not blue or bold" do
        line = %{#<i>RHINOMYRMEX</i> [subgenus of <i>Camponotus</i>]}
        @genus_catalog.parse(line).should == {:type => :subgenus, :name => 'Rhinomyrmex', :genus => 'Camponotus', :status => :valid}
      end

    end

    describe 'Material inside brackets' do

      it 'should parse the subfamily and tribe' do
        line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acromyrmex',
                                                          :subfamily => 'Myrmicinae', :tribe => 'Attini', :status => :valid}
      end

      it "should handle an extinct subfamily" do
        line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Myrmicinae]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Myrmicinae', :fossil => true, :status => :valid}
      end

      it "should handle an extinct subfamily and extinct tribe" do
        line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Specomyrminae: *Sphecomyrmini]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Protazteca',
                                                          :subfamily => 'Specomyrminae', :tribe => 'Sphecomyrmini', :fossil => true, :status => :valid}
      end

      it "should handle a parenthetical note" do
        line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae (or so they say)]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Dolichoderinae', :incertae_sedis_in => :subfamily, :status => :valid}
      end

      describe 'Incertae sedis' do
        it "should handle an uncertain family" do
          line = %{<b><i><span style='color:red'>MYANMYRMA</span></i></b> [<i>incertae sedis</i> in Formicidae]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Myanmyrma', :incertae_sedis_in => :family, :status => :valid}
        end

        it "should handle uncertainty in a family" do
          line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Dolichoderinae', :incertae_sedis_in => :subfamily, :status => :valid}
        end

        it "should handle an uncertain subfamily + tribe" do
          line = %{<b><i><span style='color:red'>ELECTROPONERA</span></i></b> [<i>incertae sedis</i> in Ectatomminae: Ectatommini]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Electroponera', :subfamily => 'Ectatomminae', :tribe => 'Ectatommini', 
                                                            :incertae_sedis_in => :tribe, :status => :valid}
        end

        it "should handle an uncertain tribe" do
          line = %{<b><i><span style='color:red'>PROPODILOBUS</span></i></b> [Myrmicinae: <i>incertae sedis</i> in Stenammini]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Propodilobus', :subfamily => 'Myrmicinae', :tribe => 'Stenammini',
                                                            :incertae_sedis_in => :tribe, :status => :valid}
        end

        it "should handle fossil" do
          line = %{*<b><i><span style='color:red'>AFROMYRMA</span></i></b><span style='color:red'> </span>[<i>incertae sedis</i> in Myrmicinae]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Afromyrma', :subfamily => 'Myrmicinae', :incertae_sedis_in => :subfamily, :fossil => true, :status => :valid}
        end

        it "should ignore a question mark" do
          line = %{<b><i><span style='color:red'>CANANEURETUS</span></i></b> [Aneuretinae?]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Cananeuretus', :subfamily => 'Aneuretinae', :status => :valid}
        end

      end

      describe 'Synonymy' do

        it "should recognize a synonym and point to its senior" do
          line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
        end

        it "should handle italic black as well as black italic" do
          line = %{<i><span style="color:black">ACALAMA</span></i> [junior synonym of <i>Gauromyrmex</i>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
        end

        it "should handle the closing bracket being in a useless span" do
          line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i><span style='font-style:normal'>]</span>}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
        end

        it "should recognize an invalid name that has no color (like Claude)" do
          line = %{<i>ACIDOMYRMEX</i> [junior synonym of <i>Rhoptromyrmex</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acidomyrmex', :status => :synonym, :synonym_of => 'Rhoptromyrmex'}
        end

        it "should handle 'Junior'" do
          line = %{<i>CRYPTOPONE</i> [Junior synonym of <i>Pachycondyla</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Cryptopone', :status => :synonym, :synonym_of => 'Pachycondyla'}
        end

        it "should recognize a fossil synonym with an italicized space" do
          line = %{*<i>ACROSTIGMA </i>[junior synonym of <i>Podomyrma</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma', 
              :fossil => true}
        end

        it "should recognize a fossil synonym of a fossil" do
          line = %{*<i>AMEGHINOIA </i>[junior synonym of *<i>Archimyrmex</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Ameghinoia', :status => :synonym, :synonym_of => 'Archimyrmex', 
              :fossil => true}
        end

        it "should handle a misspelling of 'synonym'" do
          line = %{<i>CREIGHTONIDRIS</i> [junior syonym of <i>Basiceros</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Creightonidris', :status => :synonym, :synonym_of => 'Basiceros'}
        end

        it "should handle an italicized closing bracket" do
          line = %{<i>PALAEATTA</i> [junior synonym of <i>Atta]</i>}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Palaeatta', :status => :synonym, :synonym_of => 'Atta'}
        end

        it "should handle an italicized fossil flag" do
          line = %{<i>*SINAPHAENOGASTER</i> [junior synonym of <i>Aphaenogaster</i>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Sinaphaenogaster', :status => :synonym, :synonym_of => 'Aphaenogaster',
                                                            :fossil => true}
        end

      end

      describe 'Homonymy' do

        it "should recognize a homonym and point to its senior" do
          line = %{<i>ACAMATUS</i><span style='font-style:normal'> [junior homonym, see </span><i>Neivamyrmex</i><span style='font-style:normal'>]</span>}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acamatus', :status => :homonym, :homonym_resolved_to => 'Neivamyrmex'}
        end

        it "should handle it without spans" do
          line = %{<i>ACAMATUS</i> [junior homonym, see <i>Neivamyrmex</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Acamatus', :status => :homonym, :homonym_resolved_to => 'Neivamyrmex'}
        end

        it "should handle fossil homonyms" do
          line = %{*<i>HETEROMYRMEX</i> [junior homonym, see *<i>Zhangidris</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Heteromyrmex', :status => :homonym, :homonym_resolved_to => 'Zhangidris', :fossil => true}
        end

        it "should handle a semicolon" do
          line = %{<i>TRIGONOGASTER</i> [junior homonym; see <i>Recurvidris</i>]}
          @genus_catalog.parse(line).should ==
            {:type => :genus, :name => 'Trigonogaster', :status => :homonym, :homonym_resolved_to => 'Recurvidris'}
        end

      end

      describe "Unresolved junior homonym and junior synonym" do
        it "should be its own thing" do
          line = %{<i>HOLCOPONERA </i>[junior homonym, junior synonym of <i>Cylindromyrmex</i>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Holcoponera',
                                                            :status => :unresolved_homonym_and_synonym,
                                                            :synonym_of => 'Cylindromyrmex'}
        end
        it "should handle unitalicized space" do
          line = %{<i>MYRMEX</i> [junior homonym, junior synonym of <i>Pseudomyrma</i>]}
          @genus_catalog.parse(line).should == {:type => :genus, :name => 'Myrmex',
                                                            :status => :unresolved_homonym_and_synonym,
                                                            :synonym_of => 'Pseudomyrma'}
        end
      end

      it "should handle an unresolved junior homonym in brown" do
        line = %{*<b><i><span style="color:#663300">WILSONIA</span></i></b><span style="color:red"> </span>[<i>incertae sedis</i> in Formicinae]}
        @genus_catalog.parse(line).should == {:type => :genus, :name => 'Wilsonia', :subfamily => 'Formicinae',
                                                          :incertae_sedis_in => :subfamily, :status => :unresolved_homonym,
                                                          :fossil => true}
      end
      
    end

    describe "Genus detail line" do

      it "should recognize anything beginning with tags and non-word characters, followed by a capitalized word" do
        line = %{<i style='mso-bidi-font-style:normal'>Acamatus</i> Emery, 1894c: 181 [as subgenus
  of <i style='mso-bidi-font-style:normal'>Eciton</i>]. Type-species: <i
  style='mso-bidi-font-style:normal'>Eciton (Acamatus) schmitti</i> (junior
  synonym of <i style='mso-bidi-font-style:normal'>Labidus nigrescens</i>), by
  subsequent designation of Ashmead, 1906: 24; Wheeler, W.M. 1911f: 157. [Junior
  homonym of <i style='mso-bidi-font-style:normal'>Acamatus </i>Schoenherr, 1833:
  20 (Coleoptera).]
          }
        @genus_catalog.parse(line).should == {:type => :section_detail}
      end
      
      it "should recognize anything totally inside brackets" do
        line = %{<span style="mso-spacerun: yes">  </span>[All subgenera were given as provisional junior synonyms of <i style="mso-bidi-font-style:normal">Camponotus</i> by Brown, 1973b: 179-185. The list was repeated in Hölldobler & Wilson, 1990: 18 with all subgenera listed as junior synonyms. They reverted to subgeneric status in Bolton, 1994: 50; see under individual entries. The entry of <i style="mso-bidi-font-style:normal">Myrmophyma</i> and <i style="mso-bidi-font-style:normal">Thlipsepinotus</i> under the synonymy of <i style="mso-bidi-font-style:normal">Camponotus</i> by Taylor & Brown, D.R. 1985: 109, is not accepted as confirmation as not all taxa were included.]}
        @genus_catalog.parse(line).should == {:type => :section_detail}
      end

      it "should handle space at the beginning" do
        line = %{<span style="mso-spacerun: yes"> </span><i>Cryptopone</i> junior synonym of <i>Pachycondyla</i>: Mackay & Mackay, 2010: 3.}
        @genus_catalog.parse(line).should == {:type => :section_detail}
      end

    end

    it "should handle collective group names" do
      line = %{*<i><span style="color:green">FORMICITES</span></i> [collective group name]}
      @genus_catalog.parse(line).should == {:type => :collective_group_name}
    end

    it "should handle collective group name with subfamily" do
      line = %{*<b><i><span style="color:green">MYRMECIITES</span></i></b> [Myrmeciinae: collective group name]}
      @genus_catalog.parse(line).should == {:type => :collective_group_name}
    end

  end

  describe "Importing a genus" do

    it "should make sure the subfamily exists" do
      Factory :genus, :name => 'Atta'
      lambda {
        @genus_catalog.import_genus :name => 'Atta', :status => 'homonym', :subfamily => 'Dolichoderinae'
      }.should raise_error "Genus Atta has unknown subfamily Dolichoderinae"
    end

    it "should make sure the tribe exists" do
      Factory :genus, :name => 'Atta'
      lambda {
        @genus_catalog.import_genus :name => 'Atta', :status => 'homonym', :tribe => 'Attini'
      }.should raise_error "Genus Atta has unknown tribe Attini"
    end

    describe "Adding a genus (because of status)" do

      it "should log it but add it if an existing genus is imported with a different nonnull status" do
        Progress.should_receive(:warning).with 'Adding homonym genus Atta which already existed with synonym status'
        Factory :genus, :name => 'Atta', :status => 'synonym'
        @genus_catalog.import_genus :name => 'Atta', :status => 'homonym'
        Genus.find_by_name_and_status('Atta', 'synonym').should_not be_nil
        Genus.find_by_name_and_status('Atta', 'homonym').should_not be_nil
      end

    end

    it "should not care if updating a nil status" do
      Progress.should_not_receive(:warning)
      Factory :genus, :name => 'Atta', :status => nil
      @genus_catalog.import_genus :name => 'Atta', :status => 'homonym'
      Genus.find_by_name_and_status('Atta', 'homonym').should_not be_nil
    end

  end
end
