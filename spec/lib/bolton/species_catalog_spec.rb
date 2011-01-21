require 'spec_helper'

describe Bolton::SpeciesCatalog do
  before do
    @species_catalog = Bolton::SpeciesCatalog.new
  end

  it "importing a file should call #import_html" do
    File.should_receive(:read).with('filename').and_return('contents')
    @species_catalog.should_receive(:import_html).with('contents')
    @species_catalog.import_files ['filename']
    Species.all.should be_empty
  end

  describe 'parsing the file as a whole' do
    it 'should complain bitterly if file is obviously not a species catalog' do
      contents = %{<html><body> <p>Foo</p> </body></html>}
      @species_catalog.logger.should_receive(:info).with("Couldn't parse: Foo")
      @species_catalog.import_html contents
    end

#    it "should parse a header + see-under + genus-section without complaint" do
#      contents = make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
#style='mso-bidi-font-style:normal'>ACANTHOLEPIS</i>: see under <b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'>LEPISIOTA</i></b>.</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>basispinosus</span></i></b><i style='mso-bidi-font-style:
#normal'>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14
#(s.w.) INDONESIA (Sulawesi).</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
#      }

#      @species_catalog.logger.should_not_receive(:info)
#      @species_catalog.import_html contents
#    end

  end

  describe "parsing genus see-under heading" do
    it "should recognize a simple see-under" do
      @species_catalog.parse("<i>ACANTHOLEPIS</i>: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a genus with an author" do
      @species_catalog.parse("<i>ACROSTIGMA</i> Emery: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a sub-genus" do
      @species_catalog.parse("<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct genus" do
      @species_catalog.parse("*<i>ACROSIYGMA</i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a sub-genus" do
      @species_catalog.parse("<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct sub-genus" do
      @species_catalog.parse("*<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct referent" do
      @species_catalog.parse("<i>ACANTHOMYOPS</i>: see under *<b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should not freak if there's no period at the end" do
      @species_catalog.parse("<i>AROTROPUS</i>: see under <b><i>AMBLYOPONE</i></b>").should == {:type => :see_under}
    end
    it "should not freak if there's no colon after the referer" do
      @species_catalog.parse("<i>ASKETOGENYS</i> see under <b><i>PYRAMICA</i></b><i>AROTROPUS</i>").should == {:type => :see_under}
    end
    it "should handle space between the referer and the colon" do
      @species_catalog.parse("<i>MACROMISCHOIDES</i> : see under <b><i>TETRAMORIUM</i></b>").should == {:type => :see_under}
    end
    it "should handle an italicized space" do
      @species_catalog.parse("<i>HETEROMYRMEX </i>Wheeler: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    end
    it "should handle an author with initials" do
      @species_catalog.parse("<i>HETEROMYRMEX</i>Wheeler, W.M.: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    end
    it "should handle a year after the author" do
      @species_catalog.parse("*<i>PALAEOMYRMEX</i> Dlussky, 1975: see under *<b><i>DLUSSKYIDRIS</i></b>").should == {:type => :see_under}
    end
    it "should not simply consider everything with 'see under' in it as a see-under" do
      @species_catalog.parse("*<i>PALAEOMYRMEX</i> Dlussky, 1975: see under").should == {:type => :not_understood}
    end
  end

  #describe 'parsing the genus header' do
    #before do
      #@species_contents = %q{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>brevicornis</span></i></b><i style='mso-bidi-font-style:normal'>.
#Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also:
#Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.</p>
      #}
    #end
    #it "should recognize a valid, extant genus heading" do
      #@species_catalog.import_html make_contents %{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)</p>
      ##{@species_contents}
      #}
      #Species.count.should == 1
      #Species.first.parent.name.should == 'Acanthognathus'
      #Species.first.name.should == 'brevicornis'
    #end
  #end

  #describe 'parsing a species line' do
    #before do
      #@genus_contents = %q{
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)</p>
      #}
    #end
    #it "should recognize a valid, extant species line" do
      #@species_catalog.import_html make_contents %{
      ##{@genus_contents}
#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>brevicornis</span></i></b><i style='mso-bidi-font-style:normal'>.
#Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also:
#Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.</p>
      #}
      #Species.count.should == 1
      #Species.first.parent.name.should == 'Acanthognathus'
      #Species.first.name.should == 'brevicornis'
    #end
  #end

#  describe 'a genus with a little tiny space in it' do
#    it "should still work" do
#      @species_catalog.import_html make_contents %{
#<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
#normal'><i style='mso-bidi-font-style:normal'><span style='color:red'>APHAENOGASTER</span></i></b>
#(Worldwide except Afrotropical)</p>

#<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
#style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
#style='color:red'>aktaci</span></i></b><i style='mso-bidi-font-style:normal'>.
#Aphaenogaster (Attomyrma) aktaci</i> Kiran &amp; Tezcan, in Kiran, <i
#style='mso-bidi-font-style:normal'>et al</i>. 2008: 690, fig. 1 (w.) TURKEY.</p>

#      }
#      Species.count.should == 1
#      Species.first.parent.name.should == 'Aphaenogaster'
#      Species.first.name.should == 'aktaci'
#    end
#  end

  def make_contents content
    %{
<html> <head> <title>CATALOGUE OF SPECIES-GROUP TAXA</title> </head>
<body>
<div class=Section1>
<p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE OF
SPECIES-GROUP TAXA<o:p></o:p></b></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
#{content}
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
</div> </body> </html>
    }
  end
end
