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

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamilies of
Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b style='mso-bidi-font-weight: normal'>.</b></span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamilies of
Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera
(extant) <i style='mso-bidi-font-style:normal'>incertae sedis</i> in Formicidae</span></b><span
lang=EN-GB>: <i style='mso-bidi-font-style:normal'>Condylodon</i>.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera
(extinct) <i style='mso-bidi-font-style:normal'>incertae sedis</i> in
Formicidae</span></b><span lang=EN-GB>: <i style='mso-bidi-font-style:normal'>*Calyptites</i>.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera
(extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i
style='mso-bidi-font-style:normal'><span style='color:green'>Formila</span></i>.</span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genera
(extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i
style='mso-bidi-font-style:normal'><span style='color:green'>Cariridris</span></i>.</span></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:
-36.0pt'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Genus-group <i
style='mso-bidi-font-style:normal'>nomina nuda</i> in Formicidae</span></b><span
lang=EN-GB>: <i style='mso-bidi-font-style:normal'><span style='color:purple'>Ancylognathus,
Hypopheidole, Leptoxenus, Myrmegis, Pergandea, Salticomorpha, Titusia</span></i>.</span></p>

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
    taxon.should be_nil

  end

end
