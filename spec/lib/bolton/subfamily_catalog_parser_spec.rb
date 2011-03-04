require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  it "should recognize the beginning of a genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i><span style='color:red'>ATTA</span></i> <o:p></o:p></span></b></p>
    }).should == {:type => :genus, :name => 'Atta', :status => 'valid'}
  end

  it "should recognize the beginning of a genus when the word 'Genus' is in italics, too" do
    @subfamily_catalog.parse(%{
<b><i><span lang=EN-GB style='color:black'>Genus</span><span lang=EN-GB style='color:red'> PARVIMYRMA</span></i></b>
    }).should == {:type => :genus, :name => 'Parvimyrma', :status => 'valid'}
  end

  it "should recognize a fossil genus with an extra language span" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CTENOBETHYLUS</span></i></b> </span>
    }).should == {:type => :genus, :name => 'Ctenobethylus', :fossil => true, :status => 'valid'}
  end

  it "should recognize the beginning of a fossil genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:red'>ANEURETELLUS</span></i> <o:p></o:p></span></b></p>
    }).should == {:type => :genus, :name => 'Aneuretellus', :fossil => true, :status => 'valid'}
  end

  it "should handle an empty span in there" do
    @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Genus *<i><span style="color:red">EOAENICTITES</span></i></span></b><span lang="EN-GB"> </span>
    }).should == {:type => :genus, :name => 'Eoaenictites', :fossil => true, :status => 'valid'}
  end

  it "should handle an unidentifiable genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i><span style='color:green'>HYPOCHIRA</span></i> <o:p></o:p></span></b>
    }).should == {:type => :genus, :name => 'Hypochira', :status => 'unidentifiable'}
  end

  it "should handle an unidentifiable fossil genus" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:green'>CARIRIDRIS</span></i> <o:p></o:p></span></b>
    }).should == {:type => :genus, :name => 'Cariridris', :status => 'unidentifiable', :fossil => true}
  end

  #it "should recognize this tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB> *<b style='mso-bidi-font-weight:normal'><span style='color:red'>PITYOMYRMECINI</span></b></span>
    #}).should == {:type => :tribe, :name => 'Pityomyrmecini', :fossil => true}
  #end

  #it "should recognize an incertae sedis header in tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>Stenammini</i>
    #}).should == {:type => :incertae_sedis_in_tribe_header}
  #end

  #it "should recognize Hong's incertae sedises" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera of Hong (2002), <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should recognize incertae sedis in subfamily" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should recognize extinct incertae sedis in subfamily" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in <span style='color:red'>DOLICHODERINAE<o:p></o:p></span></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should recognize a subfamily header" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ECITONINAE</span><o:p></o:p></span></b></p>
    #}).should == {:type => :subfamily_header}
  #end

  #it "should recognize another form of subfamily header" do
    #@subfamily_catalog.parse(%{
#<b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>
    #}).should == {:type => :subfamily_header}
  #end

  #it "should recognize the supersubfamily header" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>THE PONEROIDS: SUBFAMILIES AGROECOMYRMECINAE, AMBLYOPONINAE, PARAPONERINAE, PONERINAE AND PROCERATIINAE<o:p></o:p></span></b>
    #}).should == {:type => :supersubfamily_header}
  #end

  #it "should recognize the supersubfamily header when there's only one subfamily" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>
    #}).should == {:type => :supersubfamily_header}
  #end

  #it 'should handle italics in weird place' do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB style='color:black'>Genus *</span><i><span lang=EN-GB style='color:red'>HAIDOMYRMODES</span></i><span lang=EN-GB><o:p></o:p></span></b>
    #}).should == {:type => :genus, :name => 'Haidomyrmodes', :fossil => true}
  #end

  #it "should handle it when the span is before the bold and there's a subfamily at the end" do
    #@subfamily_catalog.parse(%{
#<span lang=EN-GB>Genus *<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span style='color:red'>YPRESIOMYRMA</span></i></b> [Myrmeciinae]</span>
    #}).should == {:type => :genus, :name => 'Ypresiomyrma', :fossil => true}
  #end

end
