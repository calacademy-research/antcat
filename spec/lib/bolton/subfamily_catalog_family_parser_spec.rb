require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  it "should recognize the family header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b>
    }).should == {:type => :family_header}
  end

  it "should recognize the extant subfamilies list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b>.</b></span>
    }).should == {:type => :extant_subfamilies_list, :subfamilies => ['Aenictinae', 'Myrmicinae']}
  end

  it "should recognize the extinct subfamilies list" do
    @subfamily_catalog.parse(%{
<b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span>
    }).should == {:type => :extinct_subfamilies_list, :subfamilies => ['Armaniinae', 'Brownimeciinae']}
  end

  it "should recognize the extant genera incertae sedis list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon</i>.</span>
    }).should == {:type => :extant_genera_incertae_sedis_in_family_list, :genera => ['Condylodon']}
  end

  it "should recognize the extinct genera incertae sedis list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Condylodon</i>.</span>
    }).should == {:type => :extinct_genera_incertae_sedis_in_family_list, :genera => ['Condylodon']}
  end

  it "should recognize the extant genera excluded from family list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span>
    }).should == {:type => :extant_genera_excluded_from_family_list, :genera => ['Formila']}
  end

  it "should recognize the extinct genera excluded from family list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris, *Cretacoformica</span></i>.</span>
    }).should == {:type => :extinct_genera_excluded_from_family_list, :genera => ['Cariridris', 'Cretacoformica']}
  end

  it "should recognize the genus group nomina nuda in family list" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Ancylognathus, Hypopheidole</span></i>.</span>
    }).should == {:type => :genus_group_nomina_nuda_in_family_list}
  end

  it "should recognize the genera incertae sedis in family header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :genera_incertae_sedis_in_family_header}
  end

  it "should recognize the genera excluded from family header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera excluded from <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :genera_excluded_from_family_header}
  end

  it "should recognize the unavailable family group names in family header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Unavailable family-group names in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :unavailable_family_group_names_in_family_header}
  end

  it "should recognize the genus group nomina nuda in family header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in <span style='color:red'>FORMICIDAE<o:p></o:p></span></span></b>
    }).should == {:type => :genus_group_nomina_nuda_in_family_header}
  end

end
