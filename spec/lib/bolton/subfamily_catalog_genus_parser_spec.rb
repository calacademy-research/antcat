require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Genus header" do

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

    it "should handle an unresolved homonym genus" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus *<i><span style='color:#663300'>WILSONIA</span></i><o:p></o:p></span></b>
      }).should == {:type => :genus_header, :name => 'Wilsonia', :fossil => true, :status => 'unresolved_homonym'}
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

    it "should recognize the 'genus line' that actually describes a collective group name" do
      @subfamily_catalog.parse(%{
<span lang="EN-GB">*<i style="mso-bidi-font-style:normal">Myrmeciites </i>Archibald, Cover &amp; Moreau, 2006: 500. [Collective group name.]</span>
      }).should == {:type => :genus_line, :name => 'Myrmeciites', :fossil => true}
    end

    it "should not consider normal non-boldface genus description as a genus line" do
      @subfamily_catalog.parse(%{
<span lang="EN-GB">*<i style="mso-bidi-font-style:normal">Calyptites</i> in Braconidae: Scudder, 1891: 629; Donisthorpe, 1943f: 629.</span>
      }).should == {:type => :other}
    end

    it "is a line with a non-bold first word (the taxon) if it has 'Type-species' somewhere" do
      @subfamily_catalog.parse(%{
<span lang=EN-GB>*<i>Eoaenictites</i> Hong, 2002: 541. Type-species: *<i>Eoaenictites castanifurvus</i>, by original designation.</span>
      }).should == {:type => :genus_line, :name => 'Eoaenictites', :fossil => true}
    end

    it "is a line" do
      @subfamily_catalog.parse(%{
<i><span lang="EN-GB">Propodilobus</span></i><span lang="EN-GB"> Branstetter, 2009: 54. Type-species: <i>Stenamma orientale</i> (junior homonym, replaced by <i>Stenamma pingorum</i>), by original designation.</span>    
      }).should == {:type => :genus_line, :name => 'Propodilobus'}
    end

    it "can be purple" do
      @subfamily_catalog.parse(%{
<i><span lang="EN-GB" style="color:purple">Phidologeton</span></i><span lang="EN-GB"> Bingham, 1903: 160, unjustified emendation of <i>Pheidologeton</i>. </span>
      }).should == {:type => :genus_line, :name => 'Phidologeton'}
    end

    it "shouldn't be purple like this" do
      @subfamily_catalog.parse(%{
<i><span lang="EN-GB">Apomyrma</span></i><span lang="EN-GB"> in Ponerinae, Apomyrmini: Dlussky &amp; Fedoseeva, 1988: 78 (misspelled as <span style="color:purple">Aromyrmini</span>).</span>
      }).should == {:type => :other}
    end

    it "isn't a genus line just because it has 'Type species' in it" do
      @subfamily_catalog.parse(%{
<i><span lang=EN-GB>Acrocoelia</span></i><span lang=EN-GB> as junior synonym of Crematogaster: Roger, 1863b: 36; Mayr, 1863: 404; Emery &amp; Forel, 1879a: 464; Dalla Torre, 1893: 79; Wheeler, W.M. 1911f: 158; Wheeler, W.M. 1922a: 828; Buren, 1959: 126; Kempf, 1972a: 81; Brown, 1973b: 178. [Type-species of <i>Acrocoelia</i> and <i>Crematogaster</i> are synonymous, generic synonymy is therefore absolute.]</span></p>
      }).should == {:type => :other}
    end

  end

  describe "Homonym replaced by genus header" do

    it "should be recognized" do
      @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Homonym replaced by *<i><span style='color:green'>PROMYRMICIUM</span></i><o:p></o:p></span></b>
      }).should == {:type => :homonym_replaced_by_genus_header}
    end

    it "should be recognized" do
      @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Homonym replaced by <i><span style="color:red">STIGMACROS</span></i></span></b><span lang="EN-GB" style="color:red"><p></p></span>
      }).should == {:type => :homonym_replaced_by_genus_header}
    end

    it "should be recognized as :other when a homonym-replaced-by in a synonym" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Homonym replaced by <i>Karawajewella</i> <o:p></o:p></span></b>
      }).should == {:type => :other}
    end

  end

  describe "Homonym replaced by genus synonym header" do

    it "should be recognized" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Homonym replaced by <i><span style='color:red'>Burmomoma</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span>
      }).should == {:type => :homonym_replaced_by_genus_synonym_header}
    end

  end

  describe "Junior synonym headers" do

    it "should recognize a header for the group of synonyms" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>ANEURETUS<o:p></o:p></span></i></span></b>
      }).should == {:type => :junior_synonyms_of_genus_header}
    end

    it "should recognize a header for the group of synonyms when there's only one" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Junior synonym of <i><span style='color:red'>ANEURETUS<o:p></o:p></span></i></span></b>
      }).should == {:type => :junior_synonyms_of_genus_header}
    end

    it "should recognize a header for the group of synonyms when there's a period after the closing tags" do
      @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Junior synonyms of <i><span style="color:red">ACROPYGA</span></i>.<p></p></span></b>
      }).should == {:type => :junior_synonyms_of_genus_header}
    end

    it "should be recognized when they are of a fossil" do
      @subfamily_catalog.parse(%{
<b style="mso-bidi-font-weight:normal"><span lang="EN-GB">Junior synonyms of *<i style="mso-bidi-font-style:normal"><span style="color:red">ARCHIMYRMEX<p></p></span></i></span></b>
      }).should == {:type => :junior_synonyms_of_genus_header}
    end

  end

  describe "Taxonomic history" do

    it "shouldn't make a big deal out of a purple word in the taxonomic history" do
      @subfamily_catalog.parse(%{
  <i><span lang="EN-GB" style="color:purple">Bregmatomyrmex</span></i><span lang="EN-GB"> [incorrect subsequent spelling] <i>incertae sedis</i> in Formicidae: Wheeler, G.C. &amp; Wheeler, J. 1985: 259.</span>
      }).should == {:type => :other}
    end

    it "should handle a single unitalicized letter" do
      @subfamily_catalog.parse(%{
<b style="mso-bidi-font-weight: normal"><span lang="EN-GB">Genus <span style="color:red">N<i style="mso-bidi-font-style: normal">Nylanderia</i></span> references</span></b>
      }).should == {:type => :other}
    end

  end
end
