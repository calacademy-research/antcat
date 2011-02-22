require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Importing a list of files" do

    it "should process only files beginning with numbers, and them in numerical order" do
      File.should_receive(:read).with('data/bolton/01. FORMICIDAE.htm').ordered.and_return ''
      File.should_receive(:read).with('data/bolton/02. DOLICHODEROMORPHS.htm').ordered.and_return ''
      File.should_not_receive(:read).with('data/bolton/NGC-GEN.A-L.htm')
      @subfamily_catalog.import_files ['data/bolton/NGC-GEN.A-L.htm', 'data/bolton/02. DOLICHODEROMORPHS.htm', 'data/bolton/01. FORMICIDAE.htm']
    end

  end

  describe "Importing a file" do

    it 'should add a subfamilies when it sees them' do
      @subfamily_catalog.import_html make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
</p>
<p class=MsoNormal style='margin-top:0in;margin-right:-1.25pt;margin-bottom:
0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><span lang=EN-GB>Subfamily <span
style='color:red'>CERAPACHYINAE</span> <o:p></o:p></span></b></p>
      }

      Subfamily.find_by_name('Myrmicinae').should_not be_nil
      Subfamily.find_by_name('Cerapachyinae').should_not be_nil
    end

    def make_contents content
      %{
  <html> <body lang=EN-US style='tab-interval:.5in'> <div class=Section1>
  <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
  text-indent:-.5in'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>THE
  MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>

  <p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

  <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
  text-indent:-.5in'><b style='mso-bidi-font-weight:normal'><span lang=EN-GB>SUBFAMILY
  <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b></p>

  <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span
  lang=EN-GB><o:p>&nbsp;</o:p></span></p>
  #{content}
  <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
  </div> </body> </html>
      }
    end

  end

  describe "Parsing a line" do

    it "should recognize a subfamily line" do
      @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily, :name => 'Myrmicinae'}
    end

  end

end

