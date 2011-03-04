require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Importing HTML" do
    def make_contents content
%{<html><body><div class=Section1>
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND
DOLICHODERINAE<o:p></o:p></span></b></p>
#{content}
</div></body></html>}
    end

    it "should parse a subfamily" do
      @subfamily_catalog.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Aneuretinae'
      }

      @subfamily_catalog.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>

<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p>Aneuritinae history</p>

<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribes <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *Miomyrmecini.</span></p>

<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span></p>
      }

      aneuretinae = Subfamily.find_by_name 'Aneuretinae'
      aneuretinae.taxonomic_history.should == '<p>Aneuritinae history</p>'

      aneuretini = Tribe.find_by_name 'Aneuretini'
      aneuretini.subfamily.should == aneuretinae
      aneuretinae.should_not be_fossil
      pityomyrmecini = Tribe.find_by_name 'Pityomyrmecini'
      pityomyrmecini.subfamily.should == aneuretinae
      pityomyrmecini.should be_fossil

      taxon = Genus.find_by_name 'Burmomyrma'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.should_not be_invalid

      taxon = Tribe.find_by_name 'Miomyrmecini'
      taxon.subfamily.should == aneuretinae
      taxon.incertae_sedis_in.should == 'subfamily'
    end
  #end


  #describe "Importing a file" do

    #it "should import incertae sedis in a subfamily" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-top:0cm;margin-right:-1.25pt;margin-bottom:
#0cm;margin-left:36.0pt;margin-bottom:.0001pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
#style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera <i
#style='mso-bidi-font-style:normal'>incertae sedis</i> in <span
#style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><span
#lang=EN-GB><o:p>&nbsp;</o:p></span></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
#style='mso-bidi-font-style:normal'><span style='color:red'>BURMOMYRMA</span></i>
#<o:p></o:p></span></b></p>
      #}
      #burmomyrma = Genus.find_by_name('Burmomyrma')
      #burmomyrma.incertae_sedis_in.should == 'subfamily'
      #burmomyrma.tribe.should be_nil
      #burmomyrma.subfamily.name.should == 'Aneuretinae'
    #end

    #it 'should add subfamilies and genera when it sees them' do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-top:0in;margin-right:-1.25pt;margin-bottom:
#0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
#style='color:red'>CERAPACHYINAE</span> <o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Myrmeciidae</span></b><span
#lang=EN-GB> Emery, 1877a: 71. Type-genus: <i style='mso-bidi-font-style:normal'>Myrmecia</i>.</span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB><o:p>&nbsp;</o:p></span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Myrmeciidae</span></b><span
#lang=EN-GB> Emery, 1877a: 71. Type-genus: <i style='mso-bidi-font-style:normal'>Myrmecia</i>.</span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i style='mso-bidi-font-style:
#normal'><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#lang=EN-GB>Atta</span></i></b><span lang=EN-GB> Fabricius, 1804: 421.
#Type-species: <i style='mso-bidi-font-style:normal'>Formica cephalotes</i>, by
#subsequent designation of Wheeler, W.M. 1911f: 159. </span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily *<span
#style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANEURETELLUS</span></i>
#<o:p></o:p></span></b></p>
      #}

      #Subfamily.find_by_name('Myrmicinae').should_not be_nil

      #aneuretellus = Genus.find_by_name('Aneuretellus')
      #aneuretellus.should_not be_nil
      #aneuretellus.should be_fossil
      #aneuretellus.subfamily.name.should == 'Armaniinae'
      #aneuretellus.status.should be_nil

      #armaniinae = Subfamily.find_by_name('Armaniinae')
      #armaniinae.should_not be_nil
      #armaniinae.should be_fossil
      #armaniinae.status.should be_nil

      #cerapachyinae = Subfamily.find_by_name 'Cerapachyinae'
      #cerapachyinae.should_not be_nil
      #cerapachyinae.taxonomic_history.should == 
#%{<p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Myrmeciidae</span></b><span lang=\"EN-GB\"> Emery, 1877a: 71. Type-genus: <i style=\"mso-bidi-font-style:normal\">Myrmecia</i>.</span></p><p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><span lang=\"EN-GB\"><p> </p></span></p>}

      #atta = Genus.find_by_name 'Atta'
      #atta.should_not be_nil
      #atta.tribe.name.should == 'Myrmeciini'
      #atta.tribe.subfamily.should == cerapachyinae
      #atta.tribe.status.should be_nil
      #atta.subfamily.status.should be_nil
      #atta.status.should be_nil
      #atta.taxonomic_history.should == 
#%{<p class="MsoNormal" style="margin-left:.5in;text-align:justify;text-indent:-.5in"><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span lang="EN-GB">Atta</span></i></b><span lang="EN-GB"> Fabricius, 1804: 421. Type-species: <i style="mso-bidi-font-style:normal">Formica cephalotes</i>, by subsequent designation of Wheeler, W.M. 1911f: 159. </span></p>}
    #end

    #it "should grab the full taxonomic history" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
#style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Proceratii</span></b><span
#lang=EN-GB> Emery, 1895j: 765. Type-genus: <i style='mso-bidi-font-style:normal'>Proceratium</i>.
#</span></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Taxonomic
#history<o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><span lang=EN-GB>Proceratiinae as poneromorph subfamily of Formicidae:
#Bolton, 2003: 48, 178.</span></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><span lang=EN-GB>Proceratiinae as poneroid subfamily of Formicidae:
#Ouellette, Fisher, <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 365;
#Brady, Schultz, <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 18173;
#Moreau, Bell <i style='mso-bidi-font-style:normal'>et al</i>. 2006: 102; Ward,
#2007a: 555.</span></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><span lang=EN-GB>Tribes of Proceratiinae: Probolomyrmecini,
#Proceratiini.</span></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily
#references<o:p></o:p></span></b></p>

#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>Bolton, 2003:
#48, 178 (diagnosis, synopsis); Ouellette, Fisher <i style='mso-bidi-font-style:
#normal'>et al</i>. 2006: 359 (phylogeny); Brady, Schultz, <i style='mso-bidi-font-style:
#normal'>et al</i>. 2006: 18173 (phylogeny); Moreau, Bell <i style='mso-bidi-font-style:
#normal'>et al</i>. 2006: 102 (phylogeny); Ward, 2007a: 555 (classification);
#Fernández &amp; Arias-Penna, 2008: 31 (Neotropical genera key); Yoshimura &amp;
#Fisher, 2009: 8 (Malagasy males diagnosis, key); Terayama, 2009: 96 (Taiwan
#genera key).</span></p>
      #}

      #Subfamily.find_by_name('Proceratiinae').taxonomic_history.should ==
#"<p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Proceratii</span></b><span lang=\"EN-GB\"> Emery, 1895j: 765. Type-genus: <i style=\"mso-bidi-font-style:normal\">Proceratium</i>. </span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Taxonomic history<p></p></span></b></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Proceratiinae as poneromorph subfamily of Formicidae: Bolton, 2003: 48, 178.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Proceratiinae as poneroid subfamily of Formicidae: Ouellette, Fisher, <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 365; Brady, Schultz, <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 18173; Moreau, Bell <i style=\"mso-bidi-font-style:normal\">et al</i>. 2006: 102; Ward, 2007a: 555.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\">Tribes of Proceratiinae: Probolomyrmecini, Proceratiini.</span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><span lang=\"EN-GB\"><p> </p></span></p><p class=\"MsoNormal\" style=\"margin-left:36.0pt;text-align:justify;text-indent: -36.0pt\"><b style=\"mso-bidi-font-weight:normal\"><span lang=\"EN-GB\">Subfamily references<p></p></span></b></p><p class=\"MsoNormal\" style=\"text-align:justify\"><span lang=\"EN-GB\">Bolton, 2003: 48, 178 (diagnosis, synopsis); Ouellette, Fisher <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 359 (phylogeny); Brady, Schultz, <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 18173 (phylogeny); Moreau, Bell <i style=\"mso-bidi-font-style: normal\">et al</i>. 2006: 102 (phylogeny); Ward, 2007a: 555 (classification); Fernández &amp; Arias-Penna, 2008: 31 (Neotropical genera key); Yoshimura &amp; Fisher, 2009: 8 (Malagasy males diagnosis, key); Terayama, 2009: 96 (Taiwan genera key).</span></p><p class=\"MsoNormal\" style=\"margin-left:.5in;text-align:justify;text-indent:-.5in\"><p> </p></p>"
    #end
      

    #it "should not include 'Genus incertae sedis in [...]' in the taxonomic history" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'>incertae sedis</i> in <span
#style='color:red'>Stenammini</span><o:p></o:p></span></b></p>
      #}
      #ancyridris = Genus.find_by_name 'Ancyridris'
      #ancyridris.taxonomic_history.should == ''
    #end

    #it "should not carry over the current tribe after seeing 'Genus incertae sedis in...'" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
#normal'><span lang=EN-GB>Genera <i style='mso-bidi-font-style:normal'>incertae
#sedis</i> in <span style='color:red'>FORMICINAE</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
#style='mso-bidi-font-style:normal'><span style='color:red'>CAMPONOTITES</span></i>
#<o:p></o:p></span></b></p>
      #}
      #camponotites = Genus.find_by_name 'Camponotites'
      #camponotites.tribe.should be_nil
    #end

    #it "should not include the subfamily header in the tazonomic history" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>

#<p class=MsoNormal align=center style='margin-top:0in;margin-right:-1.25pt;
#margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:center;
#text-indent:-.5in;tab-stops:6.25in'><b style='mso-bidi-font-weight:normal'><span
#lang=EN-GB>SUBFAMILY <span style='color:red'>ECITONINAE</span><o:p></o:p></span></b></p>
      #}
      #ancyridris = Genus.find_by_name 'Ancyridris'
      #ancyridris.taxonomic_history.should == ''
    #end

    #it "should handle a plus sign in the taxonomic history" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>

#<p>Panama + Columbia</p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
#style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>
      #}
      #ancyridris = Genus.find_by_name 'Ancyridris'
      #ancyridris.taxonomic_history.should == '<p>Panama + Columbia</p>'
    #end

    #it "should not translate &quot; character entity" do
      #@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>

#<p>&quot;XXX</p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
#style='color:red'>PROCERATIINAE</span><o:p></o:p></span></b></p>
      #}
      #ancyridris = Genus.find_by_name 'Ancyridris'
      #ancyridris.taxonomic_history.should == '<p>&quot;XXX</p>'
    #end

    #it "should complain if it sees the same subfamily twice" do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>
#<p>&quot;XXX</p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>
      #}}.should raise_error
    #end

    #it "should complain if it sees the same tribe twice" do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
#<p>&quot;XXX</p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
      #}}.should raise_error
    #end

    #it "should complain if it sees the same genus twice" do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>
#<p>&quot;XXX</p>
#<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
#-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i
#style='mso-bidi-font-style:normal'><span style='color:red'>ANCYRIDRIS</span></i>
#<o:p></o:p></span></b></p>
      #}}.should raise_error
    #end

    #it 'should complain if adding a genus without a tribe' do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
#</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i style='mso-bidi-font-style:
#normal'><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>
      #}}.should raise_error "Genus Atta has no tribe"
    #end

    #it "should complain if adding a genus that's incertae_sedis in subfamily without a subfamily" do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera <i
#style='mso-bidi-font-style:normal'>incertae sedis</i> in <span
#style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><span
#lang=EN-GB><o:p>&nbsp;</o:p></span></p>

#<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus *<i
#style='mso-bidi-font-style:normal'><span style='color:red'>BURMOMYRMA</span></i>
#<o:p></o:p></span></b></p>
      #}}.should raise_error "Genus Burmomyrma is incertae sedis in subfamily with no subfamily"
    #end

    #it 'should complain if adding a genus without a subfamily' do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus <i style='mso-bidi-font-style:
#normal'><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>
      #}}.should raise_error "Genus Atta has no subfamily"
    #end

    #it 'should complain if adding a tribe without a subfamily' do
      #lambda {@subfamily_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Tribe <span
#style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
      #}}.should raise_error "Tribe Myrmeciini has no subfamily"
    #end

  end

end
