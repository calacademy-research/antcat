# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
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

    it "should parse an incertae sedis list of the supersubfamily" do
      @importer.should_receive(:parse_family)
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in poneroid subfamilies</span></b><span lang=EN-GB>: *<i>Cretopone</i>, *<i>Petropone</i>.</span></p>
      }
      taxon = Genus.find_by_name 'Cretopone'
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == "supersubfamily"
      taxon = Genus.find_by_name 'Petropone'
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == "supersubfamily"
    end

    it "should parse an extinct subfamily" do
      @importer.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Armaniinae'
      }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY *<span style='color:red'>ARMANIINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Armaniinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
      }
      Subfamily.find_by_name('Armaniinae').should be_fossil
    end

    it "should parse a subfamily" do
      @importer.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Aneuretinae'
        Factory :subfamily, :name => 'Dolichoderinae'
        Factory :subfamily, :name => 'Formicinae'
      }

      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>

<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Aneuretini</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p>Aneuritinae history</p>

<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribes <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *Miomyrmecini.</span></p>

<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span></p>
<p><b><span lang=EN-GB>Genus <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Wildensis</i>. </span></p>
<p><b><span lang=EN-GB>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Curtipalpulus, *Eoleptocerites</i>
(unresolved junior homonym).</span></p>

<p><b><span lang=EN-GB>Collective group name in Myrmeciinae</span></b><span lang=EN-GB>: *<i>Myrmeciites</i>.</span></p>

<p>References</p>
<p>a references</p>

<p><b><span lang=EN-GB>Tribe <span style='color:red'>ANEURETINI</span><o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretini</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p>Aneuretini history</p>
<p><b><span lang=EN-GB>Genus (extant) of Aneuretini</span></b><span lang=EN-GB>: <i>Aneuretus</i>.</span></p>

<p><b><span lang=EN-GB>Junior synonym of <span style='color:red'>ANEURETINI<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Stictoponerini</span></b><span lang=EN-GB> Arnol'di, 1930d: 161. Type-genus: <i>Stictoponera</i> (junior synonym of <i>Gnamptogenys</i>).</span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p><span lang=EN-GB>Stictoponerini as subtribe of Aneuretini: Arnol'di, 1930d: 161.</span></p>

<p><b><span lang=EN-GB>Genera of <span style='color:red'>Aneuretini</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus <i><span style='color:red'>ANEURETUS</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Aneuretus</span></i></b></p>
<p>Aneuretus history</p>

<p><b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>ANEURETUS<o:p></o:p></span></i></span></b></p>
<p><b><i><span lang=EN-GB>Odontomyrmex</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Odontomyrmex history</p>

<p><b><span lang=EN-GB>Tribe <span style='color:red'>PITYOMYRMECINI</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Pityomyrmecini</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p>Pityomyrmecini history</p>

<p><b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>BURMOMYRMA</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Burmomyrma</span></i></b></p>
<p>Burmomyrma history</p>

<p><b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>BURMOMYRMA<o:p></o:p></span></i></span></b></p>

<p><span lang=EN-GB>*<b><i>Burmomoma</i></b> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy. </span></p>

<p><b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>Burmomoma</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span></p>
<p><b><i><span lang=EN-GB>Decamera</span></i></b><span lang=EN-GB> Roger, 1863a: 166. Type-species: <i>Decamera nigella</i>, by monotypy. </span></p>
<p><b style='mso-bidi-font-weight: normal'><span lang=EN-GB>Decamera history<o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>DOLICHODERINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB><o:p>&nbsp;</o:p></span></b></p>

<p><b><span lang=EN-GB>Subfamily <span style='color:red'>DOLICHODERINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Dolichoderinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p>Dolichoderinae history</p>
<p><b><span lang=EN-GB>Genera (extant) of Dolichoderinae</span></b><span lang=EN-GB>: <i>Stigmacros</i>.</span></p>

<p><b><span lang=EN-GB>Genera of <span style='color:red'>Dolichoderinae</span><o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>Genus <i><span style='color:red'>STIGMACROS</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Stigmacros</span></i></b><span lang=EN-GB> Forel, 1905b: 179 [as subgenus of <i>Acantholepis</i>].  </span></p>

<p><b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>STIGMACROS</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><b><i><span lang=EN-GB>Acrostigma</span></i></b><span lang=EN-GB> Forel, 1902h: 477 [as subgenus of <i>Acantholepis</i>].  Type-species: <i>Acantholepis (Acrostigma) froggatti</i>, by subsequent designation of Wheeler, W.M. 1911f: 158. </span></p>

<p><b><span lang=EN-GB>Subgenera of <i><span style='color:red'>STIGMACROS</span></i> include the nominal plus the following.<o:p></o:p></span></b></p>
<p>Subgenera note</p>
<p><b><span lang=EN-GB>Subgenus <i><span style='color:red'>STIGMACROS (MYAGROTERAS)</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Myagroteras</span></i></b><span lang=EN-GB> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</span></p>

<p><b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>STIGMACROS (MYAGROTERAS)</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span></p>
<p><b><i><span lang=EN-GB>Condylomyrma</span></i></b><span lang=EN-GB> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Condylomyrma history<o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>Subgenus <i><span style='color:red'>CAMPONOTUS (ORTHONOTOMYRMEX)</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Orthonotomyrmex</span></i></b><span lang=EN-GB> Ashmead, 1906: 31.<span style="mso-spacerun: yes">&nbsp; </span></span></p>
<p><b><span lang=EN-GB>Orthonotomyrmex history<o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>ORTHONOTOMYRMEX</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Orthonotus</span></i></b><span lang=EN-GB> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation. </span></p>
<p>Orthonotus history</p>
<p><b><span lang=EN-GB>THE FORMICOMORPHS: SUBFAMILY FORMICINAE<o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>FORMICINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>FORMICINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Formicinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p>Formicinae history</p>

      }

      aneuretinae = Subfamily.find_by_name 'Aneuretinae'
      aneuretinae.taxonomic_history.should ==
'<p><b>Aneuretini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>' +
'<p>Aneuritinae history</p>' +
'<p><b>Tribes of Aneuretinae</b>: Aneuretini, *Pityomyrmecini.</p>' +
'<p><b>Tribes <i>incertae sedis</i> in Aneuretinae</b>: *Miomyrmecini.</p>' +
'<p><b>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</b>: *<i>Burmomyrma, *Cananeuretus</i>. </p>' +
'<p><b>Genus <i>incertae sedis</i> in Aneuretinae</b>: <i>Wildensis</i>. </p>' +
'<p><b>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae</b>: *<i>Curtipalpulus, *Eoleptocerites</i> (unresolved junior homonym).</p>' +
'<p><b>Collective group name in Myrmeciinae</b>: *<i>Myrmeciites</i>.</p>' +
'<p>References</p>' +
'<p>a references</p>'

      aneuretini = Tribe.find_by_name 'Aneuretini'
      aneuretini.subfamily.should == aneuretinae
      aneuretini.should_not be_fossil
      aneuretini.taxonomic_history.should ==
%{<p><b>Aneuretini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p>Aneuretini history</p>} +
%{<p><b>Genus (extant) of Aneuretini</b>: <i>Aneuretus</i>.</p>} +
%{<p><b>Junior synonym of ANEURETINI<p></p></b></p>} +
%{<p><b>Stictoponerini</b> Arnol'di, 1930d: 161. Type-genus: <i>Stictoponera</i> (junior synonym of <i>Gnamptogenys</i>).</p>} +
%{<p><b>Taxonomic history<p></p></b></p>} +
%{<p>Stictoponerini as subtribe of Aneuretini: Arnol'di, 1930d: 161.</p>}

      stictoponerini = Tribe.find_by_name 'Stictoponerini'
      stictoponerini.should_not be_fossil
      stictoponerini.should be_invalid
      stictoponerini.status.should == 'synonym'
      stictoponerini.synonym_of.should == aneuretini

      taxon = Tribe.find_by_name 'Pityomyrmecini'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.taxonomic_history.should ==
%{<p><b>Pityomyrmecini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p>Pityomyrmecini history</p>}
      taxon = Tribe.find_by_name 'Miomyrmecini'
      taxon.subfamily.should == aneuretinae
      taxon.incertae_sedis_in.should == 'subfamily'

      burmomyrma = Genus.find_by_name 'Burmomyrma'
      burmomyrma.subfamily.should == aneuretinae
      burmomyrma.should be_fossil
      burmomyrma.incertae_sedis_in.should == 'subfamily'
      burmomyrma.should_not be_invalid
      burmomyrma.taxonomic_history.should == 
%{<p><b><i>Burmomyrma</i></b></p><p>Burmomyrma history</p>} +
%{<p><b>Junior synonyms of <i>BURMOMYRMA<p></p></i></b></p>} +
%{<p>*<b><i>Burmomoma</i></b> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy. </p>} +
%{<p><b>Homonym replaced by <i>Burmomoma</i></b><p></p></p>} +
%{<p><b><i>Decamera</i></b> Roger, 1863a: 166. Type-species: <i>Decamera nigella</i>, by monotypy. </p>} +
%{<p><b>Decamera history<p></p></b></p>}

      burmomoma = Genus.find_by_name 'Burmomoma'
      burmomoma.should be_fossil
      burmomoma.should be_invalid
      burmomoma.status.should == 'synonym'
      burmomoma.synonym_of.should == burmomyrma

      taxon = Genus.find_by_name 'Cananeuretus'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Wildensis'
      taxon.subfamily.should == aneuretinae
      taxon.should_not be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Curtipalpulus'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Eoleptocerites'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.status.should == 'unresolved homonym'

      taxon = Genus.find_by_name 'Myrmeciites'
      taxon.should be_nil

      aneuretus = Genus.find_by_name 'Aneuretus'
      aneuretus.subfamily.should == aneuretinae
      aneuretus.tribe.should == aneuretini
      aneuretus.should_not be_fossil
      aneuretus.should_not be_invalid
      aneuretus.taxonomic_history.should ==
%{<p><b><i>Aneuretus</i></b></p>} +
%{<p>Aneuretus history</p>} +
%{<p><b>Junior synonyms of <i>ANEURETUS<p></p></i></b></p>} +
%{<p><b><i>Odontomyrmex</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Odontomyrmex history</p>}

      odontomyrmex = Genus.find_by_name 'Odontomyrmex'
      odontomyrmex.subfamily.should == aneuretinae
      odontomyrmex.tribe.should == aneuretini
      odontomyrmex.should be_invalid
      odontomyrmex.taxonomic_history.should == 
%{<p><b><i>Odontomyrmex</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Odontomyrmex history</p>}
      odontomyrmex.status.should == 'synonym'
      odontomyrmex.synonym_of.should == aneuretus

      dolichoderinae = Subfamily.find_by_name 'Dolichoderinae'
      dolichoderinae.should_not be_invalid
      dolichoderinae.taxonomic_history.should == 
'<p><b>Dolichoderinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>' +
%{<p>Dolichoderinae history</p>} +
%{<p><b>Genera (extant) of Dolichoderinae</b>: <i>Stigmacros</i>.</p>}
      taxon = Subfamily.find_by_name 'Formicinae'
      taxon.should_not be_invalid
      taxon.taxonomic_history.should ==
%{<p><b>Formicinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p>Formicinae history</p>}

      stigmacros = Genus.find_by_name 'Stigmacros'
      stigmacros.should_not be_nil
      stigmacros.subgenera.map(&:name).should =~ ['Myagroteras', 'Condylomyrma', 'Orthonotomyrmex']
      stigmacros.taxonomic_history.should ==
%{<p><b><i>Stigmacros</i></b> Forel, 1905b: 179 [as subgenus of <i>Acantholepis</i>].  </p>} +

%{<p><b>Subgenera of <i>STIGMACROS</i> include the nominal plus the following.<p></p></b></p>} +
%{<p>Subgenera note</p>} +
%{<p><b>Subgenus <i>STIGMACROS (MYAGROTERAS)</i> <p></p></b></p>} +
%{<p><b><i>Myagroteras</i></b> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</p>} +
%{<p><b>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></b><p></p></p>} +
%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
%{<p><b>Condylomyrma history<p></p></b></p>} +
%{<p><b>Subgenus <i>CAMPONOTUS (ORTHONOTOMYRMEX)</i> <p></p></b></p>} +
%{<p><b><i>Orthonotomyrmex</i></b> Ashmead, 1906: 31.</p>} +
%{<p><b>Orthonotomyrmex history<p></p></b></p>} +
%{<p><b>Homonym replaced by <i>ORTHONOTOMYRMEX</i> <p></p></b></p>} +
%{<p><b><i>Orthonotus</i></b> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation. </p>} +
%{<p>Orthonotus history</p>}

      acrostigma = Genus.find_by_name 'Acrostigma'
      acrostigma.should be_homonym_replaced_by stigmacros

      myagroteras = Subgenus.find_by_name 'Myagroteras'
      myagroteras.genus.should == stigmacros
      myagroteras.taxonomic_history.should ==
%{<p><b><i>Myagroteras</i></b> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</p>} +
%{<p><b>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></b><p></p></p>} +
%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
%{<p><b>Condylomyrma history<p></p></b></p>}

      condylomyrma = Subgenus.find_by_name 'Condylomyrma'
      condylomyrma.genus.should == stigmacros
      condylomyrma.status.should == 'synonym'
      condylomyrma.synonym_of.should == myagroteras
      condylomyrma.taxonomic_history.should == 
%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
%{<p><b>Condylomyrma history<p></p></b></p>}

      orthonotomyrmex = Subgenus.find_by_name 'Orthonotomyrmex'
      orthonotomyrmex.genus.should == stigmacros
      orthonotomyrmex.taxonomic_history.should == 
%{<p><b><i>Orthonotomyrmex</i></b> Ashmead, 1906: 31.</p>} +
%{<p><b>Orthonotomyrmex history<p></p></b></p>} +
%{<p><b>Homonym replaced by <i>ORTHONOTOMYRMEX</i> <p></p></b></p>} +
%{<p><b><i>Orthonotus</i></b> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation. </p>} +
%{<p>Orthonotus history</p>}

      orthonotus = Subgenus.find_by_name 'Orthonotus'
      orthonotus.should be_nil
    end

    it "should handle a tribe with its genera lists after its synonyms instead of before" do
      @importer.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Martialinae'
        Factory :tribe, :name => 'Lasiini'
      }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB style='color:black'>SUBFAMILY</span><span lang=EN-GB> <span style='color:red'>MARTIALINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>MARTIALINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Martialinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>

<p><b><span lang=EN-GB>Tribe <span style='color:red'>LASIINI</span> <o:p></o:p></span></b></p>
<p><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Lasiini</span></b><span lang=EN-GB> Ashmead, 1905b: 384. Type-genus: <i style='mso-bidi-font-style: normal'>Lasius</i>.</span></p>

<p><b><span lang=EN-GB>Junior synonym of <span style='color:red'>LASIINI<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Acanthomyopsini</span></b><span lang=EN-GB> Donisthorpe, 1943f: 618. Type-genus: <i style='mso-bidi-font-style: normal'>Acanthomyops</i>.</span></p>

<p><b><span lang=EN-GB>Genera (extant) of Lasiini</span></b><span lang=EN-GB>: <i>Acropyga.</span></p>
      }

      Tribe.find_by_name('Lasiini').should_not be_nil
      Genus.find_by_name('Acropyga').should_not be_nil
      Tribe.find_by_name('Acanthomyopsini').should_not be_nil
    end

    it "should handle a collective group name section" do
      @importer.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Myrmicinae'
      }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB style='color:black'>SUBFAMILY</span><span lang=EN-GB> <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Myrmicinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>

<p><b><span lang=EN-GB>Collective group name in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB>*<b><i><span style='color:green'>MYRMICITES</span></i></b></span></p>
<p><span lang=EN-GB>*<b><i>Myrmicites</i></b> Förster, 1891: 448 [collective group name, without included named taxa. Note that this name is not equivalent to Myrmicites Lepeletier de Saint-Fargeau, 1835: 169.]</span></p>
      }
    end

    it "should parse a genus when there are no tribes" do
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Martialinae' }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB style='color:black'>SUBFAMILY</span><span lang=EN-GB> <span style='color:red'>MARTIALINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>MARTIALINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Martialinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus of Martialinae</span></b><span lang=EN-GB>: <i>Martialis</i>.</span></p>
<p><b><span lang=EN-GB>Genus of <span style='color:red'>Martialinae</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>MARTIALIS</span></i><o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Martialis</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Martialis history</p>
      }
      Genus.find_by_name('Martialis').taxonomic_history.should ==
%{<p><b><i>Martialis</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Martialis history</p>}
    end

    it "should handle when Miomyrmex incertae sedis in subfamily also belongs to a tribe incertae sedis in subfamily (it will be both)" do
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Dolichoderinae' }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>DOLICHODERINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>DOLICHODERINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Dolichoderinae</span></b><span lang=EN-GB> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Tribes (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *Miomyrmecini, *Zherichiniini.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *<i>Miomyrmex</i>.</span></p>
<p><b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Miomyrmecini</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Miomyrmex</i> (see under: Genera <i>incertae sedis</i> in Dolichoderinae, below).</span></p>

<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in <span style='color:red'>DOLICHODERINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>MIOMYRMEX</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Miomyrmex</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Miomyrmex history</p>
      }
      miomyrmecini = Tribe.find_by_name 'Miomyrmecini'
      miomyrmecini.should_not be_nil
      miomyrmecini.incertae_sedis_in.should == 'subfamily'

      miomyrmex = Genus.all :conditions => ['name = ?', 'Miomyrmex']
      miomyrmex.count.should == 1
      miomyrmex = miomyrmex.first
      miomyrmex.incertae_sedis_in.should == 'subfamily'
      miomyrmex.tribe.should == miomyrmecini
    end

    it "should handle genera incertae sedis in tribe" do
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Aneuretinae' }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribe <span style='color:red'>ANEURETINI</span><o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretini</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus (extant) of Aneuretini</span></b><span lang=EN-GB>: *<i>Miomyrmex</i>.</span></p>
<p><b><span lang=EN-GB>Genus<i> incertae sedis</i> in Aneuretini</span></b><span lang=EN-GB>:<i> Aulacopone</i>.</span></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>MIOMYRMEX</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Miomyrmex</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Miomyrmex history</p>
<p><b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>Heteroponerini</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>AULACOPONE</span></i><o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Aulacopone</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Aulacopone history</p>
      }
      taxon = Genus.find_by_name 'Miomyrmex'
      taxon.taxonomic_history.should == 
%{<p><b><i>Miomyrmex</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Miomyrmex history</p>}
    end

    it "should allow a taxon which has been added from a list (all of them, hopefully) to be subsequently changed to unidentifiable" do
      @importer.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Aneuretinae' }
      @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribe <span style='color:red'>ANEURETINI</span><o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretini</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genus of Aneuretini</span></b><span lang=EN-GB>: <i>Tricytarus</i>.</span></p>
<p><b><span lang=EN-GB>Genus <i><span style='color:green'>TRICYTARUS</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang=EN-GB>Tricytarus</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
      }
      taxon = Genus.find_by_name 'Tricytarus'
      taxon.status.should == 'unidentifiable'
    end

    describe "situations where line needs to be preprocessed, not just parsed" do
      it "should handle a spacerun in the middle" do
        @importer.should_receive(:parse_family).and_return {
          Factory :subfamily, :name => 'Aneuretinae'
          Factory :tribe, :name => 'Miomyrmecini'
        }
        @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Miomyrmecini</span></p>
<p><b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Miomyrmecini</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p><b><span lang=EN-GB>Genera of Miomyrmecini</span></b><span lang=EN-GB>: <i>Eutetramorium, *Protomyrmica, <span style="mso-spacerun: yes">&nbsp;</span>Secostruma</i>.</span></p>
        }
        taxon = Genus.find_by_name 'Eutetramorium'
        taxon.should_not be_fossil
        taxon = Genus.find_by_name 'Protomyrmica'
        taxon.should be_fossil
        taxon = Genus.find_by_name 'Secostruma'
        taxon.should_not be_fossil
      end
    end

    describe "taxonomic history" do
      before do
        @importer.should_receive(:parse_family).and_return {Factory :subfamily, :name => 'Aneuretinae'}
        @contents = %{
  <p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
  <p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
  <p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
        }
      end

      it "should handle a plus sign in the taxonomic history" do
        @importer.import_html make_contents @contents + '<p>Panama + Columbia</p>'
        Taxon.find_by_name('Aneuretinae').taxonomic_history.should == 
%{<p><b>Aneuretinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p>Panama + Columbia</p>}
      end

      it "should not translate &quot; character entity" do
        @importer.import_html make_contents @contents + '<p>&quot;XXX</p>'
        Taxon.find_by_name('Aneuretinae').taxonomic_history.should ==
%{<p><b>Aneuretinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p>&quot;XXX</p>}
      end

    end

    describe "Cleaning up taxonomic history" do
      it "should remove all attributes and spans" do
        @importer.should_receive(:parse_family).and_return {Factory :subfamily, :name => 'Aneuretinae'}
        @contents = %{
        }
        @importer.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>
<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:
normal'><span style='color:red'>lundii</span></i></b><i style='mso-bidi-font-style:
normal'>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger,
1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.).
Combination in <i style='mso-bidi-font-style:normal'>Atta</i>: Roger, 1863a:
200; in <i style='mso-bidi-font-style:normal'>Atta (Acromyrmex</i>): Forel,
1885a: 356; in <i style='mso-bidi-font-style:normal'>Acromyrmex</i>: Forel,
1913l: 237. Senior synonym of <i style='mso-bidi-font-style:normal'>bonariensis</i>:
Gallardo, 1916d: 331; of <i style='mso-bidi-font-style:normal'>risii</i>:
Santschi, 1925a: 384; of <i style='mso-bidi-font-style:normal'>dubia</i>:
Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal
plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>boliviensis,
carli, decolor, parallelus</span></i>.</p>
        }
        Taxon.find_by_name('Aneuretinae').taxonomic_history.should ==
%{<p><b>Aneuretinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p><b><i>lundii</i></b><i>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger, } +
%{1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.). } +
%{Combination in <i>Atta</i>: Roger, 1863a: } +
%{200; in <i>Atta (Acromyrmex</i>): Forel, } +
%{1885a: 356; in <i>Acromyrmex</i>: Forel, } +
%{1913l: 237. Senior synonym of <i>bonariensis</i>: } +
%{Gallardo, 1916d: 331; of <i>risii</i>: } +
%{Santschi, 1925a: 384; of <i>dubia</i>: } +
%{Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal } +
%{plus <i>boliviensis, } +
%{carli, decolor, parallelus</i>.</p>}
      end

    end
  end
end
