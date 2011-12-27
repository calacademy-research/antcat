# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do

  it "should convert the HTML to an intermediate form and send it to Family.import" do
    Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
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

<p>Genus <i>CONDYLODON</i></p>
<p><i>Condylodon</i> Lund, 1831a: 131. Type-species: <i>Condylodon audouini</i>, by monotypy. </p>
<p>Taxonomic history</p>
<p><i>Condylodon</i> in family Mutillidae?: Swainson &amp; Shuckard, 1840: 173. </p>

<p>Genera excluded from FORMICIDAE</p>
<p>The following were all originally described as members of Formicidae but are now excluded.</p>

<p>Unavailable family-group names in FORMICIDAE</p>

<p>Genus-group <i>nomina nuda</i> in FORMICIDAE</p>

</div></body></html>
    }
    data =  {
      :protonym => {
        :name => "Formicariae",
        :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
      },
      :type_genus => 'Formica'
    }

    Bolton::Catalog::Subfamily::Importer.new.import_html html

    family = Family.first
    family.name.should == 'Formicidae'
    family.should_not be_nil
    family.should_not be_invalid
    family.should_not be_fossil
    family.type_taxon.name.should == 'Formica'

    genus = Genus.find_by_name 'Condylodon'
    genus.should_not be_nil
    genus.should_not be_invalid
    genus.should_not be_fossil
  end

end
