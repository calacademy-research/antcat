# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  it "should import the family" do
    reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Latreille')], :citation_year => '1809'
    Reference.should_receive(:find_by_bolton_author_year).and_return reference

    @importer.import_html %{
<html><body><div class=Section1>
<p><b>FAMILY FORMICIDAE</b></p>
<p><b>Family <span style='color:red'>FORMICIDAE</span> </b></p>
<p><b>Formicariae</b> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</p>
<p><b>Taxonomic history</b></p>
<p>Formicidae as family: Latreille, 1809: 124 [Formicariae]; all subsequent authors. </p>
</div></body></html>
    }

    taxon = Family.find_by_name 'Formicidae'
    taxon.should_not be_invalid
    taxon.should_not be_fossil
    protonym = taxon.protonym
    protonym.name.should == 'Formicariae'
    authorship = protonym.authorship
    authorship.pages.should == '124'
    #reference = authorship.reference
    #reference.year.should == 1809
    #reference.author_names.should == ['Latreille']

#<p><b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b style='mso-bidi-font-weight: normal'>.</b></span></p>
#<p><b><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span></p>

#<p><b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon, Hypochira</i>.</span></p>
#<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Calyptites</i>.</span></p>

#<p><b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span></p>
#<p><b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris, *Promyrmicium, Cretacoformica</span></i>.</span></p>

#<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Hypopheidole</span></i>.</span></p>

#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight: normal'><span lang=EN-GB>FAMILY <span style='color:red'>FORMICIDAE</span> REFERENCES, WORLD <o:p></o:p></span></b></p>

#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>WORLD CATALOGUES</span></p>
#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>Roger, 1863b: 1 (Formicidae); Mayr, 1863: 394 (Formicidae); Dalla Torre, 1893: 1 (Formicidae); Emery, 1910b: 3 (Dorylinae); Emery, 1911d: 2 (Ponerinae); Emery, 1913a: 2 (Dolichoderinae); Emery, 1921f: 3, Emery, 1922e: 95 and Emery, 1924d: 207 (Myrmicinae); Emery, 1925b: 2 (Formicinae); Shattuck, 1994: 1 (Aneuretinae and Dolichoderinae); Bolton, 1995b: 7 (Formicidae).</span></p>

#<p>Regional catalogues and checklists</p>
#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>NEARCTIC: Smith, M.R., 1951a: 778; Smith, M.R. 1958c: 108 (first supplement to previous); Smith, M.R. 1967: 343 (second supplement); Smith, D.R. 1979: 1323.</span></p>

#<p>Regional and national faunas with keys</p>
#<p>PALEARCTIC</p>
#<p>Bolton, 2002: 123.</p>

#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
#normal'><span lang=EN-GB>GENERA <i style='mso-bidi-font-style:normal'>INCERTAE
#SEDIS</i> AND EXCLUSIONS FROM <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>

#<p><b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>

#<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CALYPTITES</span></i></b> </span></p>
#<p><b><i><span lang="EN-GB">Calyptites</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
#<p>Taxonomic history</p>
#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB>*<i
#style='mso-bidi-font-style:normal'>Calyptites</i> in Braconidae: Scudder, 1891:
#629; Donisthorpe, 1943f: 629.</span></p>
#<p>Genus references</p>
#<p>Baroni Urbani, 1977c: 482 (review of genus).</p>

#<p><b>Genus <i>CONDYLODON</i></b></p>
#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight: normal'><i style='mso-bidi-font-style:normal'><span lang=EN-GB>Condylodon</span></i></b><span lang=EN-GB> Lund, 1831a: 131. Type-species: <i style='mso-bidi-font-style:normal'>Condylodon audouini</i>, by monotypy. </span></p>
#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight: normal'><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
#<p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style: normal'><span lang=EN-GB>Condylodon</span></i><span lang=EN-GB> in family Mutillidae?: Swainson &amp; Shuckard, 1840: 173. </span></p>
#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

#<p><b><span lang=EN-GB>Genera excluded from <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
#<p><span lang=EN-GB>The following were all originally described as members of Formicidae but are now excluded.</span></p>

#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight: normal'><span lang=EN-GB>Genus *<i style='mso-bidi-font-style:normal'><span style='color:green'>PROMYRMICIUM</span></i> <o:p></o:p></span></b></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span lang=EN-GB>*<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style: normal'>Promyrmicium</i></b> Baroni Urbani, 1971b: 362. </span></p>
#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight: normal'><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB>[Replacement name for *<i style='mso-bidi-font-style:normal'>Myrmicium</i>
#Heer, 1870: 78; junior homonym of *<i style='mso-bidi-font-style:normal'>Myrmicium</i>
#Westwood, 1854: 396.] </span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><span lang=EN-GB>Homonym replaced by *<i
#style='mso-bidi-font-style:normal'><span style='color:green'>PROMYRMICIUM</span></i><o:p></o:p></span></b></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB>*<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:
#normal'>Myrmicium</i></b> Heer, 1870: 78. Type-species: *<i style='mso-bidi-font-style:
#normal'>Myrmicium boreale</i>, by monotypy. </span></p>
#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
#normal'><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB>[Junior homonym of *<i style='mso-bidi-font-style:normal'>Myrmicium</i>
#Westwood, 1854: 396 (*Pseudosiricidae).] </span></p>

#<p><b><span lang=EN-GB>Unavailable family-group names in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>

#<p><span lang=EN-GB style='color:purple'>ALLOFORMICINAE</span><span lang=EN-GB> [unavailable name]</span></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB>Alloformicinae Emery, 1925b: 9 [as &quot;section&quot; of
#Formicinae]. Section designated to include tribes Melophorini, Myrmelachistini
#and Plagiolepidini. Unavailable name; not based on genus rank taxon. Contained
#material referable to Formicinae: Bolton, 1994: 51.</span></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
#lang=EN-GB><span style="mso-spacerun: yes">&nbsp; </span>Promyrmicinae: Forel,
#1917: 240 [incorrect expansion of the above unavailable name to include tribes
#Metaponini and Pseudomyrmini]. Unavailable name.</span></p>

#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
#normal'><span lang=EN-GB>Genus-group <i style='mso-bidi-font-style:normal'>nomina
#nuda</i> in <span style='color:red'>FORMICIDAE<o:p></o:p></span></span></b></p>
#<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
#style='mso-bidi-font-style:normal'><span lang=EN-GB style='color:purple'>HYPOPHEIDOLE</span></i><span
#lang=EN-GB> [<i style='mso-bidi-font-style:normal'>nomen nudum</i>]</span></p>
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
#style='mso-bidi-font-style:normal'><span lang=EN-GB>Hypopheidole</span></i><span
#lang=EN-GB> Ashmead, 1905b: 383, <i style='mso-bidi-font-style:normal'>nomen
#nudum</i>.</span></p>
#</body></html>

    #taxon = Subfamily.find_by_name 'Aenictinae'
    #taxon.should_not be_invalid
    #taxon.should_not be_fossil
    #taxon = Subfamily.find_by_name 'Myrmicinae'
    #taxon.should_not be_invalid
    #taxon.should_not be_fossil

    #taxon = Subfamily.find_by_name 'Armaniinae'
    #taxon.should_not be_invalid
    #taxon.should be_fossil
    #taxon = Subfamily.find_by_name 'Brownimeciinae'
    #taxon.should_not be_invalid
    #taxon.should be_fossil

    #taxon = Genus.find_by_name 'Condylodon'
    ##taxon.should_not be_invalid
    #taxon.should_not be_fossil
    #taxon.incertae_sedis_in.should == 'family'
    #taxon.taxonomic_history.should ==
#"<p><b><i>Condylodon</i></b> Lund, 1831a: 131. Type-species: <i>Condylodon audouini</i>, by monotypy. </p><p><b>Taxonomic history<p></p></b></p><p><i>Condylodon</i> in family Mutillidae?: Swainson & Shuckard, 1840: 173. </p>"

    #taxon = Genus.find_by_name 'Calyptites'
    ##taxon.should_not be_invalid
    #taxon.should be_fossil
    #taxon.incertae_sedis_in.should == 'family'
    #taxon.taxonomic_history.should ==
#"<p><b><i>Calyptites</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p><p>Taxonomic history</p><p><i>&dagger;Calyptites</i> in Braconidae: Scudder, 1891: 629; Donisthorpe, 1943f: 629.</p>" +
#"<p>Genus references</p>" +
#"<p>Baroni Urbani, 1977c: 482 (review of genus).</p>"

    #taxon = Genus.find_by_name 'Hypochira'
    ##taxon.status.should == 'unidentifiable'
    #taxon.incertae_sedis_in.should == 'family'

    #taxon = Genus.find_by_name 'Formila'
    ##taxon.should be_invalid
    #taxon.should_not be_fossil
    ##taxon.status.should == 'excluded'

    #taxon = Genus.find_by_name 'Cariridris'
    ##taxon.should be_invalid
    #taxon.should be_fossil
    #taxon.status.should == 'excluded'
    #taxon.taxonomic_history.should be_nil

    #taxon = Genus.find_by_name 'Hypopheidole'
    ##taxon.should be_invalid
    ##taxon.status.should == 'nomen nudum'
    #taxon.taxonomic_history.should ==
#%{<p><i>Hypopheidole</i> Ashmead, 1905b: 383, <i>nomen nudum</i>.</p>}

    #cretacoformica = Genus.find_by_name 'Cretacoformica'
    #cretacoformica.should be_invalid
    #cretacoformica.status.should == 'excluded'
    #cretacoformica.should be_fossil
  end

end
