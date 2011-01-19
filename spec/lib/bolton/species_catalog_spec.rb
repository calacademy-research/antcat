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

  describe 'parsing the genus header' do
    before do
      @species_contents = %q{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>brevicornis</span></i></b><i style='mso-bidi-font-style:normal'>.
Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also:
Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.</p>
      }
    end
    it "should recognize a valid, extant genus heading" do
      @species_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)</p>
      #{@species_contents}
      }
      Species.count.should == 1
      Species.first.parent.name.should == 'Acanthognathus'
      Species.first.name.should == 'brevicornis'
    end
  end

  describe 'parsing a species line' do
    before do
      @genus_contents = %q{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)</p>
      }
    end
    it "should recognize a valid, extant species line" do
      @species_catalog.import_html make_contents %{
      #{@genus_contents}
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>brevicornis</span></i></b><i style='mso-bidi-font-style:normal'>.
Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also:
Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.</p>
      }
      Species.count.should == 1
      Species.first.parent.name.should == 'Acanthognathus'
      Species.first.name.should == 'brevicornis'
    end
  end

  describe 'a genus with a little tiny space in it' do
    it "should still work" do
      @species_catalog.import_html make_contents %{
<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><span style='color:red'>APHAENOGASTER</span></i></b>
(Worldwide except Afrotropical)</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>aktaci</span></i></b><i style='mso-bidi-font-style:normal'>.
Aphaenogaster (Attomyrma) aktaci</i> Kiran &amp; Tezcan, in Kiran, <i
style='mso-bidi-font-style:normal'>et al</i>. 2008: 690, fig. 1 (w.) TURKEY.</p>

      }
      Species.count.should == 1
      Species.first.parent.name.should == 'Aphaenogaster'
      Species.first.name.should == 'aktaci'
    end
  end

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
