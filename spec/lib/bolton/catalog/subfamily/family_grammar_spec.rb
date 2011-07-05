require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  it "should recognize the family header" do
    @importer.parse(%{
<b><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b>
    }).should == {:type => :family_header}
  end

  it "should recognize the extant subfamilies list" do
    @importer.parse(%{
<b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b>.</b></span>
    }).should == {:type => :extant_subfamilies_list, :subfamilies => ['Aenictinae', 'Myrmicinae']}
  end

  it "should recognize the extinct subfamilies list" do
    @importer.parse(%{
<b style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span>
    }).should == {:type => :extinct_subfamilies_list, :subfamilies => ['Armaniinae', 'Brownimeciinae']}
  end

  it "should recognize the extant genera incertae sedis list" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon</i>.</span>
    }).should == {:type => :extant_genera_incertae_sedis_in_family_list, :genera => ['Condylodon']}
  end

  it "should recognize the extinct genera incertae sedis list" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Condylodon</i>.</span>
    }).should == {:type => :extinct_genera_incertae_sedis_in_family_list, :genera => ['Condylodon']}
  end

  it "should recognize the extant genera excluded from family list" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span>
    }).should == {:type => :extant_genera_excluded_from_family_list, :genera => ['Formila']}
  end

  it "should recognize the extinct genera excluded from family list" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris, *Cretacoformica</span></i>.</span>
    }).should == {:type => :extinct_genera_excluded_from_family_list, :genera => ['Cariridris', 'Cretacoformica']}
  end

  it "should recognize the genus group nomina nuda in family list, even if one of them is a fossil" do
    @importer.parse(%{
<b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Ancylognathus, *Hypopheidole</span></i>.</span>
    }).should == {:type => :genus_group_nomina_nuda_in_family_list, :genera => [{:name => 'Ancylognathus'}, {:name => 'Hypopheidole', :fossil => true}]}
  end

  it "should recognize the genera incertae sedis in family header" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :genera_incertae_sedis_in_family_header}
  end

  it "should recognize the genera excluded from family header" do
    @importer.parse(%{
<b><span lang=EN-GB>Genera excluded from <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :genera_excluded_from_family_header}
  end

  it "should recognize the unavailable family group names in family header" do
    @importer.parse(%{
<b><span lang=EN-GB>Unavailable family-group names in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b>
    }).should == {:type => :unavailable_family_group_names_in_family_header}
  end

  it "should recognize the genus group nomina nuda in family header" do
    @importer.parse(%{
<b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in <span style='color:red'>FORMICIDAE<o:p></o:p></span></span></b>
    }).should == {:type => :genus_group_nomina_nuda_in_family_header}
  end

  describe "Family-group line" do

    it "should recognize a tribe line" do
      @importer.parse(%{
  <b><span lang="EN-GB">Acanthomyopsini</span></b><span lang="EN-GB"> Donisthorpe, 1943f: 618. Type-genus: <i>Acanthomyops</i>.</span>
      }).should == {:type => :family_group_line, :name => 'Acanthomyopsini'}
    end

    it "should recognize a family line" do
      @importer.parse(%{
<b><span lang=EN-GB>Formicariae</span></b><span lang=EN-GB> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</span>
      }).should == {:type => :family_group_line, :name => 'Formicariae'}
    end

    it "should recognize an extinct tribe line" do
      @importer.parse(%{
<span lang="EN-GB">*<b style="mso-bidi-font-weight:normal">Pityomyrmecini</b> Wheeler, W.M. 1915h: 98. Type-genus: *<i style="mso-bidi-font-style:normal">Pityomyrmex</i>.</span>
      }).should == {:type => :family_group_line, :name => 'Pityomyrmecini'}
    end

    it "should recognize this" do
      @importer.parse(%{
<b><span lang="EN-GB">Anonychomyrmini</span></b><span lang="EN-GB"> Donisthorpe, 1947c: 588. Type-genus: <i style="mso-bidi-font-style: normal">Anonychomyrma</i>.</span>
      }).should == {:type => :family_group_line, :name => 'Anonychomyrmini'}
    end

    it "should handle an errant space" do
      @importer.parse(%{
<b> <span lang="EN-GB">Stictoponerini</span></b><span lang="EN-GB"> Arnol'di, 1930d: 161. Type-genus: <i>Stictoponera</i> (junior synonym of <i>Gnamptogenys</i>).</span>
      }).should == {:type => :family_group_line, :name => 'Stictoponerini'}
    end

    it "should handle an errant space" do
      @importer.parse(%{
<b><span lang="EN-GB" style="color:black">Bothriomyrmecina</span></b><span lang="EN-GB" style="color:black"> </span><span lang="EN-GB">Dubovikov, 2005: 92. Type-genus: <i>Bothriomyrmex</i>.</span>
      }).should == {:type => :family_group_line, :name => 'Bothriomyrmecina'}
    end

  end
    
end
