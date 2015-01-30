# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do

  it "should import Formicidae" do
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

<p>WORLD CATALOGUES</p>
<p>Roger, 1863b: 1 (Formicidae).</p>

<p>Regional catalogues and checklists</p>
<p>NEARCTIC: Latreille, 1809: 778.</p>

<p>Regional and national faunas with keys</p>
<p>PALAEARCTIC</p>
<p>Mayr, 1855: 299.</p>

<p>GENERA <i>INCERTAE SEDIS</i> AND EXCLUSIONS FROM FORMICIDAE</p>
<p>Genera <i>incertae sedis</i> in FORMICIDAE</p>

<p>Genus *<i>CONDYLODON</i></p>
<p>*<i>Condoleeza</i> Lund, 1831a: 131. Type-species: <i>Condylodon audouini</i>, by monotypy. [Lund, 1831a: 25 says no.]</p>
<p>Taxonomic history</p>
<p><i>Condylodon</i> in family Mutillidae: Swainson &amp; Shuckard, 1840: 173. </p>

<p>Genus references</p>
<p>Baroni Urbani, 1977c: 482 (review of genus).</p>

<p>Genera excluded from FORMICIDAE</p>
<p>The following were all originally described as members of Formicidae but are now excluded.</p>

<p>Genus *<i>PROMYRMICIUM</i></p>
<p>*<i>Promyrmicium</i> Baroni Urbani, 1971b: 362. </p>

<p>Homonym replaced by *<i>PROMYRMICIUM</i></p>
<p>*<i>Myrmicium</i> Heer, 1870: 78. Type-species: *<i>Myrmicium boreale</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p>[Junior homonym of *<i>Myrmicium</i> Westwood, 1854: 396 (*Pseudosiricidae).] </p>

<p>Unavailable family-group names in FORMICIDAE</p>
<p>ALLOFORMICINAE [unavailable name]</p>
<p>Alloformicinae Emery, 1925b: 9 [as "section" of Formicinae]. Section designated to include tribe Melophorini: Bolton, 1994: 51.</p>
<p>Promyrmicinae: Forel, 1917: 240 [incorrect expansion of the above unavailable name to include tribes Metaponini and Pseudomyrmini]. Unavailable name.</p>

<p>Genus-group <i>nomina nuda</i> in FORMICIDAE</p>

</div></body></html>
    }

    latreille = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
    mayr = FactoryGirl.create :article_reference, :bolton_key_cache => 'Mayr 1855'
    lund = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Lund 1831a'
    swainson = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Swainson Shuckard 1840'
    baroni = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Baroni Urbani 1977c'
    roger = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Roger 1863b'
    bolton = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Bolton 1994'
    emery = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Emery 1925b'
    forel = FactoryGirl.create :unknown_reference, :bolton_key_cache => 'Forel 1917'

    Importers::Bolton::Catalog::Subfamily::Importer.new.import_html html

    family = Family.first
    expect(family.name.to_s).to eq('Formicidae')
    expect(family).not_to be_invalid
    expect(family).not_to be_fossil
    expect(family.type_name.to_s).to eq('Formica')
    expect(family.type_name.rank).to eq('genus')
    expect(family.history_items.map(&:taxt)).to match_array([
      %{Formicidae as family: {ref #{latreille.id}}: 124 [{nam #{Name.find_by_name('Formicariae').id}}]; all subsequent authors}
    ])

    expect(family.size).to eq(3)
    reference_section = family.reference_sections.first
    expect(reference_section.title_taxt).to eq('FAMILY FORMICIDAE REFERENCES, WORLD')
    expect(reference_section.subtitle_taxt).to eq('WORLD CATALOGUES')
    expect(reference_section.references_taxt).to eq("{ref #{roger.id}}: 1 ({tax #{Taxon.find_by_name('Formicidae').id}})")

    reference_section = family.reference_sections.second
    expect(reference_section.title_taxt).to eq('Regional catalogues and checklists')
    expect(reference_section.subtitle_taxt).to be_blank
    expect(reference_section.references_taxt).to eq("NEARCTIC: {ref #{latreille.id}}: 778")

    reference_section = family.reference_sections.third
    expect(reference_section.title_taxt).to eq('Regional and national faunas with keys')
    expect(reference_section.subtitle_taxt).to eq('PALAEARCTIC')
    expect(reference_section.references_taxt).to eq("{ref #{mayr.id}}: 299")

    genus = Genus.find_by_name 'Condylodon'
    expect(genus).not_to be_invalid
    expect(genus).to be_fossil
    expect(genus).to be_incertae_sedis_in 'family'
    expect(genus.subfamily).to be_nil
    expect(genus.history_items.map(&:taxt)).to match_array([
      "{nam #{Name.find_by_name('Condylodon').id}} in family {nam #{Name.find_by_name('Mutillidae').id}}: {ref #{swainson.id}}: 173."
    ])
    expect(genus.type_name.to_s).to eq("Condylodon audouini")
    expect(genus.type_taxt).to eq(", by monotypy. [{ref #{lund.id}}: 25 says no.]")
    expect(genus.reference_sections.map(&:title_taxt)).to eq(["Genus references"])
    expect(genus.reference_sections.map(&:references_taxt)).to eq(["{ref #{baroni.id}}: 482 (review of genus)."])

    genus = Genus.find_by_name 'Promyrmicium'
    expect(genus).to be_fossil
    expect(genus).to be_excluded_from_formicidae
    protonym = genus.protonym
    expect(protonym.name.to_s).to eq('Promyrmicium')
    expect(protonym.name.rank).to eq('genus')
    expect(protonym.fossil).to be_truthy
    protonym.authorship
    protonym.sic

    genus = Genus.find_by_name 'Myrmicium'
    expect(genus).to be_homonym
    expect(genus).to be_fossil
    expect(genus.homonym_replaced_by.name.to_s).to eq('Promyrmicium')

    subfamily = Subfamily.find_by_name 'Alloformicinae'
    expect(subfamily.status).to eq('unavailable')
    expect(subfamily.protonym.name.to_s).to eq('Alloformicinae')
    expect(subfamily.headline_notes_taxt).to eq(" Section designated to include tribe {nam #{Name.find_by_name('Melophorini').id}}: {ref #{bolton.id}}: 51.")
    expect(subfamily.history_items.map(&:taxt)).to match_array([
      "{nam #{Name.find_by_name('Promyrmicinae').id}}: {ref #{forel.id}}: 240 [incorrect expansion of the above unavailable name to include tribes {nam #{Name.find_by_name('Metaponini').id}} and {nam #{Name.find_by_name('Pseudomyrmini').id}}]. Unavailable name."
    ])
  end

end
