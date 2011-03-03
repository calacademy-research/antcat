require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  def make_contents content
    %{<html><body><div class=Section1>#{content}</div></body></html>}
  end

  it "should parse the family summary section" do
    @subfamily_catalog.stub! :parse_family_detail
    @subfamily_catalog.import_html make_contents %{
<p><b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b></p>
<p><b><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b style='mso-bidi-font-weight: normal'>.</b></span></p>
<p><b><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span></p>

<p><b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon</i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Calyptites</i>.</span></p>

<p><b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris</span></i>.</span></p>

<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Hypopheidole</span></i>.</span></p>
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

    taxon = Genus.find_by_name 'Calyptites'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon.incertae_sedis_in.should == 'family'

    taxon = Genus.find_by_name 'Formila'
    taxon.should be_invalid
    taxon.should_not be_fossil
    taxon.status.should == 'excluded'

    taxon = Genus.find_by_name 'Cariridris'
    taxon.should be_invalid
    taxon.should be_fossil
    taxon.status.should == 'excluded'

    taxon = Genus.find_by_name 'Hypopheidole'
    taxon.should be_invalid
    taxon.status.should == 'nomen nuda'

  end

end
