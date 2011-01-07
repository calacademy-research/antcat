require 'spec_helper'

describe Bolton::GenusCatalog do
  before do
    @genus_catalog = Bolton::GenusCatalog.new
  end

  describe 'importing files' do
    it "should call #import_html with the contents of each one" do
      File.should_receive(:read).with('first_filename').and_return('first contents')
      File.should_receive(:read).with('second_filename').and_return('second contents')
      @genus_catalog.should_receive(:import_html).with('first contents')
      @genus_catalog.should_receive(:import_html).with('second contents')
      @genus_catalog.import_files ['first_filename', 'second_filename']
    end
  end

  describe 'importing html' do
    it "should call the parser for each <p> and save the result" do
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return :genus => {:name => 'bar'}
      Bolton::GenusCatalogParser.should_receive(:parse).with('bar').and_return :genus => {:name => 'foo'}
      Genus.should_receive(:create!).with(:name => 'bar').and_return Factory :genus
      Genus.should_receive(:create!).with(:name => 'foo').and_return Factory :genus
      @genus_catalog.import_html '<html><p>foo</p><p>bar</p></html>'
    end

    it "should not save the result if it wasn't a genus" do
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return nil
      Genus.should_not_receive :create!
      @genus_catalog.import_html '<html><p>foo</p></html>'
    end

    describe "processing a representative sample and making sure they're saved correctly" do
      it 'should import a fossil genus' do
        @genus_catalog.import_html make_content %Q{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ALLOIOMMA</span></i></b> [<i style='mso-bidi-font-style:normal'>incertae
sedis</i> in Dolichoderinae]</p>
        }
        Genus.count.should == 1
        Genus.first.should be_fossil
      end
    end

    def make_content content
      %Q{<html> <head> <title>CATALOGUE OF GENUS-GROUP TAXA</title> </head>
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

end
