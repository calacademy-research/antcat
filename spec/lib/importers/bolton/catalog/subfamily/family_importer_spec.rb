# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
  end

  it "should parse the family" do
    @importer.import_html %{
<html><body><div class=Section1>

<p><b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b></p>
<p><b><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Family <span style='color:red'>FORMICIDAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Formicariae</span></b><span lang=EN-GB> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b style='mso-bidi-font-weight: normal'>.</b></span></p>
<p><b><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span></p>

<p><b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon, Hypochira</i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Calyptites</i>.</span></p>

<p><b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris, Cretacoformica</span></i>.</span></p>

<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Hypopheidole</span></i>.</span></p>

<p><b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CALYPTITES</span></i></b> </span></p>
<p><b><i><span lang="EN-GB">Calypitites</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Calyptites taxonomic history</p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> <b><i><span style='color:red'>CONDYLODON</span></i></b> </span></p>
<p><b><i><span lang="EN-GB">Condylodon</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Condylodon taxonomic history</p>
<p><b><span lang=EN-GB>Genus <i><span style='color:green'>HYPOCHIRA</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang="EN-GB">Hypochira</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>SYNTAPHUS</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang="EN-GB">Syntaphus</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genera excluded from <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB>The following were all originally described as members of Formicidae but are now excluded.</span></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:green'>CARIRIDRIS</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang="EN-GB">Cariridris</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Cariridris taxonomic history</p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>CRETACOFORMICA</span></i> <o:p></o:p></span></b></p>
<p><b><i><span lang="EN-GB">Cretacoformica</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>

<p><b><span lang=EN-GB>Homonym replaced by *<i><span style='color:green'>CRETACOFORMICA</span></i><o:p></o:p></span></b></p>
<p><span lang=EN-GB>*<b><i>Myrmicium</i></b> Heer, 1870: 78.  Type-species: *<i>Myrmicium boreale</i>, by
monotypy. </span></p>
<p><b><span lang=EN-GB>Taxonomic history<o:p></o:p></span></b></p>
<p><span lang=EN-GB>[Junior homonym of *<i style='mso-bidi-font-style: normal'>Myrmicium</i> Westwood, 1854: 396 (*Pseudosiricidae).] </span></p>

<p><b><span lang=EN-GB>Unavailable family-group names in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB style='color:purple'>ALLOFORMICINAE</span><span lang=EN-GB> [unavailable name]</span></p>

<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in <span style='color:red'>FORMICIDAE<o:p></o:p></span></span></b></p>
<p><i style='mso-bidi-font-style:normal'><span lang=EN-GB style='color:purple'>HYPOPHEIDOLE</span></i><span lang=EN-GB> [<i>nomen nudum</i>]</span></p>
<p><b><i><span lang="EN-GB">Hypopheidole</span></i></b><span lang="EN-GB"> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span></p>
<p>Hypopheidole history</p>

</div></body></html>
    }

    taxon = Subfamily.find_by_name 'Aenictinae'
    taxon.should_not be_invalid
    taxon.should_not be_fossil
    taxon = Subfamily.find_by_name 'Myrmicinae'
    taxon.should_not be_invalid
    taxon.should_not be_fossil

    taxon = Subfamily.find_by_name 'Armaniinae'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon = Subfamily.find_by_name 'Brownimeciinae'
    taxon.should_not be_invalid
    taxon.should be_fossil

    taxon = Genus.find_by_name 'Condylodon'
    taxon.should_not be_invalid
    taxon.should_not be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should ==
%{<p><b><i>Condylodon</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Condylodon taxonomic history</p>}

    taxon = Genus.find_by_name 'Calyptites'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should ==
%{<p><b><i>Calypitites</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Calyptites taxonomic history</p>}

    taxon = Genus.find_by_name 'Hypochira'
    taxon.status.should == 'unidentifiable'
    taxon.incertae_sedis_in.should == 'family'

    taxon = Genus.find_by_name 'Formila'
    taxon.should be_invalid
    taxon.should_not be_fossil
    taxon.status.should == 'excluded'

    taxon = Genus.find_by_name 'Cariridris'
    taxon.should be_invalid
    taxon.should be_fossil
    taxon.status.should == 'excluded'
    taxon.taxonomic_history.should ==
%{<p><b><i>Cariridris</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Cariridris taxonomic history</p>}

    taxon = Genus.find_by_name 'Hypopheidole'
    taxon.should be_invalid
    taxon.status.should == 'nomen nudum'
    taxon.taxonomic_history.should ==
%{<p><b><i>Hypopheidole</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
%{<p>Hypopheidole history</p>}

    taxon = Genus.find_by_name 'Syntaphus'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should ==
%{<p><b><i>Syntaphus</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>}

    cretacoformica = Genus.find_by_name 'Cretacoformica'
    cretacoformica.should be_invalid
    cretacoformica.should be_fossil
    cretacoformica.status.should == 'excluded'
    cretacoformica.taxonomic_history.should == 
%{<p><b><i>Cretacoformica</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>}

    taxon = Genus.find_by_name 'Myrmicium'
    taxon.should be_homonym_replaced_by cretacoformica

  end

end
