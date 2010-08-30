require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoltonImporter do
  describe "importing genera" do
    it "should do nothing if the file is empty" do
      File.should_receive(:read).with('subfamily_genus.txt').and_return('')
      BoltonImporter.new.get_subfamilies('subfamily_genus.txt')
      Genus.all.should be_empty 
    end

    it "should handle the first entries" do
      contents = make_contents <<-CONTENTS
      <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
          style='color:black'>ACALAMA</span></i> [junior synonym of <i style='mso-bidi-font-style:
        normal'>Gauromyrmex</i>]</p>

      <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
        style='mso-bidi-font-style:normal'>Acalama</i> Smith, M.R. 1949a: 206.
      Type-species: <i style='mso-bidi-font-style:normal'>Acalama donisthorpei</i>
      (junior synonym of <i style='mso-bidi-font-style:normal'>Solenomyrma acanthina</i>),
      by original designation. </p>
      CONTENTS

      File.should_receive(:read).with('subfamily_genus.txt').and_return(contents)
      BoltonImporter.new.get_subfamilies('subfamily_genus.txt')
    end
  end

  def make_contents content
    "<html>
        <body>
      <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
      text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE OF
        GENUS-GROUP TAXA<o:p></o:p></b></p>

      <p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

      <p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

      #{content}
        </body>
      </html>
    "
  end
end
