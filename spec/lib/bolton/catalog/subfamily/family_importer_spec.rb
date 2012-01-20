# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do

  it "should convert the HTML to an intermediate form and send it to Family.import" do
    html = %{
<html><body><div class=Section1>
<p><b>FAMILY FORMICIDAE</b></p>
<p><b>Family <span style='color:red'>FORMICIDAE</span> </b></p>
<p><b>Formicariae</b> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</p>
<p><b>Taxonomic history</b></p>
<p>Formicidae as family: Latreille, 1809: 124 [Formicariae]; all subsequent authors. </p>

<p>Subfamilies of Formicidae (extant): Aenictinae.</p>
<p>Subfamilies of Formicidae (extinct): *Sphecomyrminae.</p>
<p>Genera (extant) <i>incertae sedis</i> in Formicidae: <i>Condylodon</i>.</p>
<p>Genera (extinct) <i>incertae sedis</i> in Formicidae: <i>*Calyptites</i>.</p>
<p>Genera (extant) excluded from Formicidae: <i>Formila</i>.</p>
<p>Genera (extinct) excluded from Formicidae: *<i>Cariridris</i>.</p>
<p>Genus-group <i>nomina nuda</i> in Formicidae: <i>Ancylognathus</i>.</p>

<p>FAMILY FORMICIDAE REFERENCES, WORLD</p>
<p>WORLD CATALOGUES</p><p>Roger, 1863b: 1 (Formicidae).</p>
<p>Regional catalogues and checklists</p><p>NEARCTIC: Smith, M.R., 1951a: 778.</p>
<p>Regional and national faunas with keys</p><p>PALAEARCTIC</p><p>Mayr, 1855: 299 (Austria).</p>

<p>GENERA <i>INCERTAE SEDIS</i> AND EXCLUSIONS FROM FORMICIDAE</p>
<p>Genera <i>incertae sedis</i> in FORMICIDAE</p>

<p>Genus *<i>CONDYLODON</i></p>
<p>*<i>Condoleeza</i> Lund, 1831a: 131. Type-species: <i>Condylodon audouini</i>, by monotypy. [Lund, 1831a: 25 says no.]</p>
<p>Taxonomic history</p>
<p><i>Condylodon</i> in family Mutillidae: Swainson &amp; Shuckard, 1840: 173. </p>

<p>Genus references</p><p>Baroni Urbani, 1977c: 482 (review of genus).</p>

<p>Genera excluded from FORMICIDAE</p>
<p>The following were all originally described as members of Formicidae but are now excluded.</p>

<p>Genus *<i>PROMYRMICIUM</i></p>
<p>*<i>Promyrmicium</i> Baroni Urbani, 1971b: 362. </p>

<p>Homonym replaced by *<i>PROMYRMICIUM</i></p>
<p>*<i>Myrmicium</i> Heer, 1870: 78. Type-species: *<i>Myrmicium boreale</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p>[Junior homonym of *<i>Myrmicium</i> Westwood, 1854: 396 (*Pseudosiricidae).] </p>
<p>Unavailable family-group names in FORMICIDAE</p>

<p>Genus-group <i>nomina nuda</i> in FORMICIDAE</p>

</div></body></html>
    }

    latreille = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
    lund = Factory :unknown_reference, :bolton_key_cache => 'Lund 1831a'
    swainson = Factory :unknown_reference, :bolton_key_cache => 'Swainson Shuckard 1840'
    baroni = Factory :unknown_reference, :bolton_key_cache => 'Baroni Urbani 1977c'

    Bolton::Catalog::Subfamily::Importer.new.import_html html

    family = Family.first
    family.name.should == 'Formicidae'
    family.should_not be_invalid
    family.should_not be_fossil
    family.type_taxon.name.should == 'Formica'
    family.taxonomic_history_items.map(&:taxt).should =~ [
      %{Formicidae as family: {ref #{latreille.id}}: 124 [Formicariae]; all subsequent authors}
    ]

    genus = Genus.find_by_name 'Condylodon'
    genus.should_not be_invalid
    genus.should be_fossil
    genus.should be_incertae_sedis_in 'family'
    genus.subfamily.should be_nil
    genus.taxonomic_history_items.map(&:taxt).should =~ [
      "<i>Condylodon</i> in family Mutillidae: {ref #{swainson.id}}: 173"
    ]
    genus.type_taxon_name.should == "Condylodon audouini"
    genus.type_taxon_taxt.should == ", by monotypy. [{ref #{lund.id}}: 25 says no.]"

    species = genus.type_taxon
    species.should_not be_invalid
    species.name.should == 'audouini'

    # this belongs in genus_importer_spec
    genus = Genus.find_by_name 'Promyrmicium'
    genus.should be_fossil
    genus.should be_excluded
    protonym = genus.protonym
    protonym.name.should == 'Promyrmicium'
    protonym.rank.should == 'genus'
    protonym.fossil.should be_true
    protonym.authorship
    protonym.sic

    genus = Genus.find_by_name 'Myrmicium'
    genus.should be_homonym
    genus.should be_fossil
    genus.homonym_replaced_by.name.should == 'Promyrmicium'
  end

end
