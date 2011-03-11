require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  it "should recognize the usual supersubfamily header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE<o:p></o:p></span></b>
    }).should == {:type => :supersubfamily_header}
  end

  it "should recognize the supersubfamily header when there's only one subfamily" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>
    }).should == {:type => :supersubfamily_header}
  end

  it "should recognize the supersubfamily header for extinct subfamilies" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>EXTINCT SUBFAMILIES OF FORMICIDAE: *ARMANIINAE, *BROWNIMECIINAE, *FORMICIINAE, *SPHECOMYRMINAE<o:p></o:p></span></b>
    }).should == {:type => :supersubfamily_header}
  end

  it "should recognize a genus header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>
    }).should == {:type => :genus_header, :name => 'Atta', :status => 'valid'}
  end

  it "should recognize a genus header when the word 'Genus' is in italics, too" do
    @subfamily_catalog.parse(%{
<b><i><span lang=EN-GB style='color:black'>Genus</span><span lang=EN-GB style='color:red'> PARVIMYRMA</span></i></b>
    }).should == {:type => :genus_header, :name => 'Parvimyrma', :status => 'valid'}
  end

  describe "Genus line" do

    it "should recognize a genus line" do
      @subfamily_catalog.parse(%{
<b><i><span lang=EN-GB>Odontomyrmex</span></i></b><span lang=EN-GB> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </span>
      }).should == {:type => :genus_line, :name => 'Odontomyrmex'}
    end

    it "should recognize a fossil genus line" do
      @subfamily_catalog.parse(%{
<span lang=EN-GB>*<b><i>Calyptites</i></b> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy. </span>
      }).should == {:type => :genus_line, :name => 'Calyptites', :fossil => true}
    end

  end

  it "should recognize a fossil genus with an extra language span" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CTENOBETHYLUS</span></i></b> </span>
    }).should == {:type => :genus_header, :name => 'Ctenobethylus', :fossil => true, :status => 'valid'}
  end

  it "should recognize the beginning of a fossil genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:red'>ANEURETELLUS</span></i> <o:p></o:p></span></b></p>
    }).should == {:type => :genus_header, :name => 'Aneuretellus', :fossil => true, :status => 'valid'}
  end

  it "shouldn't make a big deal out of a purple word in the taxonomic history" do
    @subfamily_catalog.parse(%{
<i><span lang="EN-GB" style="color:purple">Bregmatomyrmex</span></i><span lang="EN-GB"> [incorrect subsequent spelling] <i>incertae sedis</i> in Formicidae: Wheeler, G.C. &amp; Wheeler, J. 1985: 259.</span>
    }).should == {:type => :other}
  end

  it "should handle an empty span in there" do
    @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Genus *<i><span style="color:red">EOAENICTITES</span></i></span></b><span lang="EN-GB"> </span>
    }).should == {:type => :genus_header, :name => 'Eoaenictites', :fossil => true, :status => 'valid'}
  end

  it "should handle an unidentifiable genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i><span style='color:green'>HYPOCHIRA</span></i> <o:p></o:p></span></b>
    }).should == {:type => :genus_header, :name => 'Hypochira', :status => 'unidentifiable'}
  end

  it "should handle an unidentifiable fossil genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:green'>CARIRIDRIS</span></i> <o:p></o:p></span></b>
    }).should == {:type => :genus_header, :name => 'Cariridris', :status => 'unidentifiable', :fossil => true}
  end

  it "should handle an unavailable genus" do
    @subfamily_catalog.parse(%{
<i><span lang=EN-GB style='color:purple'>ANCYLOGNATHUS</span></i><span lang=EN-GB> [<i>nomen nudum</i>]</span>
    }).should == {:type => :genus_header, :name => 'Ancylognathus', :status => 'unavailable'}
  end

  it "should handle it when the span is before the bold and there's a subfamily at the end" do
    @subfamily_catalog.parse(%{
<span lang=EN-GB>Genus *<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span style='color:red'>YPRESIOMYRMA</span></i></b> [Myrmeciinae]</span>
    }).should == {:type => :genus_header, :name => 'Ypresiomyrma', :fossil => true, :status => 'valid'}
  end

  it 'should handle italics in weird place' do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB style='color:black'>Genus *</span><i><span lang=EN-GB style='color:red'>HAIDOMYRMODES</span></i><span lang=EN-GB><o:p></o:p></span></b>
    }).should == {:type => :genus_header, :name => 'Haidomyrmodes', :fossil => true, :status => 'valid'}
  end

end
