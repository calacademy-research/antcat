require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoltonImporter do
  describe "importing genera" do
    it "should do nothing if the file is empty" do
      File.should_receive(:read).with('subfamily_genus.html').and_return('')
      BoltonImporter.new.get_subfamilies('subfamily_genus.html')
      Genus.all.should be_empty 
    end

    it "should handle the first entries" do
      contents = <<-CONTENTS
        <html 
          <head>
          </head>
          <body lang=EN-US style='tab-interval:.5in'>
            <div class=Section1>
              <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
              text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE OF
                GENUS-GROUP TAXA<o:p></o:p></b></p>
              <p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>
              <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

              <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
              style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
              style='color:red'>AMBLYOPONE</span></i></b> [Amblyoponinae]</p>

              <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
              style='mso-bidi-font-style:normal'>Amblyopone</i> Erichson, 1842: 260.
              Type-species: <i style='mso-bidi-font-style:normal'>Amblyopone australis</i>,
              by monotypy. </p>

              <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
              style='mso-bidi-font-style:normal'>Amblyopone</i> senior synonym of <i
              style='mso-bidi-font-style:normal'>Stigmatomma</i>: Emery &amp; Forel, 1879:
              455; Mayr, 1887: 546.</p>

              <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>
            </div>
          </body>
        </html>
      CONTENTS

      File.should_receive(:read).with('subfamily_genus.html').and_return(contents)
      BoltonImporter.new.get_subfamilies('subfamily_genus.html').should == [{:genus => 'Amblyopone'}]
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
