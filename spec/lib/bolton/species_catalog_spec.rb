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

  describe "importing a species record" do
    it "should import a species record" do
      contents = make_contents "contents"
      @species_catalog.import_html contents
      species = Species.first
      #species.authors.should == 'Abe, M. & Smith, D.R.'
    end
  end

  def make_contents content
    "<html>
        <body>
<p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE REFERENCES<o:p></o:p></b></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#{content}
</p>
        </body>
      </html>
    "
  end
end
