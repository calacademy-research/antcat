require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Importing a list of files" do

    it "should process only files beginning with numbers, and them in numerical order" do
      File.should_receive(:read).with('data/bolton/01. FORMICIDAE.htm').ordered.and_return ''
      File.should_receive(:read).with('data/bolton/02. DOLICHODEROMORPHS.htm').ordered.and_return ''
      File.should_not_receive(:read).with('data/bolton/NGC-GEN.A-L.htm')
      @subfamily_catalog.import_files ['data/bolton/NGC-GEN.A-L.htm', 'data/bolton/02. DOLICHODEROMORPHS.htm', 'data/bolton/01. FORMICIDAE.htm']
    end

  end

  describe "Importing a file" do

    it 'should add subfamilies and genera when it sees them' do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
</p>

<p class=MsoNormal style='margin-top:0in;margin-right:-1.25pt;margin-bottom:
0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
style='color:red'>CERAPACHYINAE</span> <o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Myrmeciidae</span></b><span
lang=EN-GB> Emery, 1877a: 71. Type-genus: <i style='mso-bidi-font-style:normal'>Myrmecia</i>.</span></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Myrmeciidae</span></b><span
lang=EN-GB> Emery, 1877a: 71. Type-genus: <i style='mso-bidi-font-style:normal'>Myrmecia</i>.</span></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i style='mso-bidi-font-style:
normal'><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
lang=EN-GB>Atta</span></i></b><span lang=EN-GB> Fabricius, 1804: 421.
Type-species: <i style='mso-bidi-font-style:normal'>Formica cephalotes</i>, by
subsequent designation of Wheeler, W.M. 1911f: 159. </span></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily *<span
style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
style='mso-bidi-font-style:normal'><span style='color:red'>ANEURETELLUS</span></i>
<o:p></o:p></span></b></p>
      }

      Subfamily.find_by_name('Myrmicinae').should_not be_nil

      aneuretellus = Genus.find_by_name('Aneuretellus')
      aneuretellus.should_not be_nil
      aneuretellus.should be_fossil
      aneuretellus.subfamily.name.should == 'Armaniinae'

      armaniinae = Subfamily.find_by_name('Armaniinae')
      armaniinae.should_not be_nil
      armaniinae.should be_fossil

      cerapachyinae = Subfamily.find_by_name 'Cerapachyinae'
      cerapachyinae.should_not be_nil
      cerapachyinae.taxonomic_history.should == 
%{<p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Myrmeciidae</span></b><span lang=\"EN-GB\"> Emery, 1877a: 71. Type-genus: <i style=\"mso-bidi-font-style:normal\">Myrmecia</i>.</span></p><p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><span lang=\"EN-GB\"><p> </p></span></p>}

      atta = Genus.find_by_name 'Atta'
      atta.should_not be_nil
      atta.tribe.name.should == 'Myrmeciini'
      atta.taxonomic_history.should == 
%{<p class="MsoNormal" style="margin-left:.5in;text-align:justify;text-indent:-.5in"><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span lang="EN-GB">Atta</span></i></b><span lang="EN-GB"> Fabricius, 1804: 421. Type-species: <i style="mso-bidi-font-style:normal">Formica cephalotes</i>, by subsequent designation of Wheeler, W.M. 1911f: 159. </span></p>}
    end

    it "should grab the full taxonomic history" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Proceratii</span></b><span
lang=EN-GB> Emery, 1895j: 765. Type-genus: <i style='mso-bidi-font-style:normal'>Proceratium</i>.
</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Taxonomic
history<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><span lang=EN-GB>Proceratiinae as poneromorph subfamily of Formicidae:
Bolton, 2003: 48, 178.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><span lang=EN-GB>Proceratiinae as poneroid subfamily of Formicidae:
Ouellette, Fisher, <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 365;
Brady, Schultz, <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 18173;
Moreau, Bell <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 102; Ward,
2007a: 555.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><span lang=EN-GB>Tribes of Proceratiinae: Probolomyrmecini,
Proceratiini.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily
references<o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>Bolton, 2003:
48, 178 (diagnosis, synopsis); Ouellette, Fisher <i style='mso-bidi-font-style:
normal'>et al</i>. 2006: 359 (phylogeny); Brady, Schultz, <i style='mso-bidi-font-style:
normal'>et al</i>. 2006: 18173 (phylogeny); Moreau, Bell <i style='mso-bidi-font-style:
normal'>et al</i>. 2006: 102 (phylogeny); Ward, 2007a: 555 (classification);
Fernández &amp; Arias-Penna, 2008: 31 (Neotropical genera key); Yoshimura &amp;
Fisher, 2009: 8 (Malagasy males diagnosis, key); Terayama, 2009: 96 (Taiwan
genera key).</span></p>
      }

      Subfamily.find_by_name('Proceratiinae').taxonomic_history.should ==
"<p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Proceratii</span></b><span lang=\"EN-GB\"> Emery, 1895j: 765. Type-genus: <i style=\"mso-bidi-font-style:normal\">Proceratium</i>. </span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Taxonomic history<p></p></span></b></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Proceratiinae as poneromorph subfamily of Formicidae: Bolton, 2003: 48, 178.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Proceratiinae as poneroid subfamily of Formicidae: Ouellette, Fisher, <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 365; Brady, Schultz, <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 18173; Moreau, Bell <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 102; Ward, 2007a: 555.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Tribes of Proceratiinae: Probolomyrmecini, Proceratiini.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\"><p> </p></span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Subfamily references<p></p></span></b></p><p class=\"MsoNormal\" style=\"text-align:justify\"><span lang=\"EN-GB\">Bolton, 2003: 48, 178 (diagnosis, synopsis); Ouellette, Fisher <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 359 (phylogeny); Brady, Schultz, <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 18173 (phylogeny); Moreau, Bell <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 102 (phylogeny); Ward, 2007a: 555 (classification); Fernández &amp; Arias-Penna, 2008: 31 (Neotropical genera key); Yoshimura &amp; Fisher, 2009: 8 (Malagasy males diagnosis, key); Terayama, 2009: 96 (Taiwan genera key).</span></p><p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><p> </p></p>"
    end
      

    it "should not include 'Genus incertae sedis in [...]' in the taxonomic history" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'>incertae sedis</i> in <span
style='color:red'>Stenammini</span><o:p></o:p></span></b></p>
      }
      ancyridris = Genus.find_by_name 'Ancyridris'
      ancyridris.taxonomic_history.should == ''
    end

    it "should not carry over the current tribe after seeing 'Genus incertae sedis in...'" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>Genera <i style='mso-bidi-font-style:normal'>incertae
sedis</i> in <span style='color:red'>FORMICINAE</span><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
style='mso-bidi-font-style:normal'><span style='color:red'>CAMPONOTITES</span></i>
<o:p></o:p></span></b></p>
      }
      camponotites = Genus.find_by_name 'Camponotites'
      camponotites.tribe.should be_nil
    end

    it "should not include the subfamily header in the tazonomic history" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='margin-top:0in;margin-right:-1.25pt;
margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:center;
text-indent:-.5in;tab-stops:6.25in'><b style='mso-bidi-font-weight:normal'><span
lang=EN-GB>SUBFAMILY <span style='color:red'>ECITONINAE</span><o:p></o:p></span></b></p>
      }
      ancyridris = Genus.find_by_name 'Ancyridris'
      ancyridris.taxonomic_history.should == ''
    end

    it "should handle a plus sign in the taxonomic history" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>

<p>Panama + Columbia</p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>
      }
      ancyridris = Genus.find_by_name 'Ancyridris'
      ancyridris.taxonomic_history.should == '<p>Panama + Columbia</p>'
    end

    it "should not translate &quot; character entity" do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>

<p>&quot;XXX</p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>
      }
      ancyridris = Genus.find_by_name 'Ancyridris'
      ancyridris.taxonomic_history.should == '<p>&quot;XXX</p>'
    end

    it "should complain if it sees the same subfamily twice" do
      lambda {@subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
</p>
<p>&quot;XXX</p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
</p>
      }}.should raise_error
    end

    it "should complain if it sees the same tribe twice" do
      lambda {@subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
<p>&quot;XXX</p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
      }}.should raise_error
    end

    it "should complain if it sees the same genus twice" do
      lambda {@subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>
<p>&quot;XXX</p>
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
<o:p></o:p></span></b></p>
      }}.should raise_error
    end

    def make_contents content
      %{
  <html> <body lang=EN-US style='tab-interval:.5in'> <div class=Section1>
  <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
  text-indent:-.5in'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>THE
  MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>

  <p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

  <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
  text-indent:-.5in'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>SUBFAMILY
  <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b></p>

  <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
  lang=EN-GB><o:p>&nbsp;</o:p></span></p>
  #{content}
  <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
  </div> </body> </html>
      }
    end

  end

  describe "Parsing a line" do

    it "should recognize a subfamily line" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily, :name => 'Myrmicinae'}
    end

    it "should recognize an extinct subfamily line" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>
      }).should == {:type => :subfamily, :name => 'Armaniinae', :fossil => true}
    end

    it "should recognize the beginning of a tribe" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Tribe <span style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
      }).should == {:type => :tribe, :name => 'Myrmeciini'}
    end

    it "should recognize the beginning of a fossil tribe" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b>
      }).should == {:type => :tribe, :name => 'Miomyrmecini', :fossil => true}
    end

    it "should recognize the beginning of a genus" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>
      }).should == {:type => :genus, :name => 'Atta'}
    end

    it "should recognize the beginning of a genus when the word 'Genus' is in italics, too" do
      @subfamily_catalog.parse(%{
<b><i><span lang=EN-GB style='color:black'>Genus</span><span lang=EN-GB style='color:red'> PARVIMYRMA</span></i></b>
      }).should == {:type => :genus, :name => 'Parvimyrma'}
    end

    it "should recognize a fossil genus with an extra language span" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CTENOBETHYLUS</span></i></b> </span>
      }).should == {:type => :genus, :name => 'Ctenobethylus', :fossil => true}
    end

    it "should recognize the beginning of a fossil genus" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:red'>ANEURETELLUS</span></i> <o:p></o:p></span></b></p>
      }).should == {:type => :genus, :name => 'Aneuretellus', :fossil => true}
    end

    it "should handle an empty span in there" do
      @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Genus *<i><span style="color:red">EOAENICTITES</span></i></span></b><span lang="EN-GB"> </span>
      }).should == {:type => :genus, :name => 'Eoaenictites', :fossil => true}
    end

    it "should recognize this tribe" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB> *<b style='mso-bidi-font-weight:normal'><span style='color:red'>PITYOMYRMECINI</span></b></span>
      }).should == {:type => :tribe, :name => 'Pityomyrmecini', :fossil => true}
    end

    it "should recognize an incertae sedis header in tribe" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>Stenammini</i>
      }).should == {:type => :genus_incertae_sedis_in_tribe}
    end

    it "should recognize Hong's incertae sedises" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera of Hong (2002), <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
      }).should == {:type => :genus_incertae_sedis_in_subfamily}
    end

    it "should recognize incertae sedis in subfamily" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
      }).should == {:type => :genus_incertae_sedis_in_subfamily}
    end

    it "should recognize extinct incertae sedis in subfamily" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in <span style='color:red'>DOLICHODERINAE<o:p></o:p></span></span></b>
      }).should == {:type => :genus_incertae_sedis_in_subfamily}
    end

    it "should recognize a subfamily header" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ECITONINAE</span><o:p></o:p></span></b></p>
      }).should == {:type => :subfamily_header}
    end

    it "should recognize another form of subfamily header" do
      @subfamily_catalog.parse(%{
<b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>
      }).should == {:type => :subfamily_header}
    end

    it "should recognize the supersubfamily header" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE PONEROIDS: SUBFAMILIES AGROECOMYRMECINAE, AMBLYOPONINAE, PARAPONERINAE, PONERINAE AND PROCERATIINAE<o:p></o:p></span></b>
      }).should == {:type => :supersubfamily_header}
    end

    it "should recognize the supersubfamily header when there's only one subfamily" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>
      }).should == {:type => :supersubfamily_header}
    end

  end
end

