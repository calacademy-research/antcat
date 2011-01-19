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
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return :genus => {:name => 'foo'}
      Bolton::GenusCatalogParser.should_receive(:parse).with('bar').and_return :genus => {:name => 'bar'}
      Genus.should_receive(:find_or_create_by_name).with(:name => 'bar', :is_valid => nil, :taxonomic_history=>"<p>bar</p>", :parent => nil).and_return Factory :genus
      Genus.should_receive(:find_or_create_by_name).with(:name => 'foo', :is_valid => nil, :taxonomic_history=>"<p>foo</p>", :parent => nil).and_return Factory :genus
      @genus_catalog.import_html '<html><p>foo</p><p>bar</p></html>'
    end

    it "should not save the result if it wasn't a genus" do
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return :unidentifiable
      Taxon.should_not_receive :create!
      @genus_catalog.import_html '<html><p>foo</p></html>'
    end

    describe "processing a representative sample and making sure they're saved correctly" do
      it 'should work' do
        @genus_catalog.import_html make_content %{
<p>asdfdsfsdf</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:blue'>ALAOPONE</span></i></b> [subgenus of <i style='mso-bidi-font-style:
normal'>Dorylus</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]</p>

<p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
style='color:black'>ACALAMA</span></i> [junior synonym of <i style='mso-bidi-font-style:
normal'>Gauromyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i
style='mso-bidi-font-style:normal'>Lasius</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'><span style='color:purple'>ANCYLOGNATHUS</span></i>
[<i style='mso-bidi-font-style:normal'>Nomen nudum</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>PROTAZTECA</span></i></b> [<i style='mso-bidi-font-style:
normal'>incertae sedis</i> in Dolichoderinae]</p>

        }
        Genus.count.should == 4

        acromyrmex = Genus.find_by_name 'Acromyrmex'
        acromyrmex.should_not be_fossil
        acromyrmex.parent.parent.name.should == 'Myrmicinae'
        acromyrmex.parent.name.should == 'Attini'
        acromyrmex.is_valid.should be_true
        acromyrmex.taxonomic_history.should == %{<p class="MsoNormal" style="margin-left:.5in;text-align:justify;text-indent:-.5in"><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:red">ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>}

        acalama = Genus.find_by_name 'Acalama'
        acalama.should_not be_fossil
        acalama.is_valid.should_not be_true

        ancylognathus = Genus.find_by_name 'Ancylognathus'
        ancylognathus.should_not be_available
        ancylognathus.is_valid.should_not be_true
        
        protazteca = Genus.find_by_name 'Protazteca'
        protazteca.parent.name.should == 'incertae_sedis'
        protazteca.parent.parent.name.should == 'Dolichoderinae'
        
      end
    end

    def make_content content
      %{<html> <head> <title>CATALOGUE OF GENUS-GROUP TAXA</title> </head>
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
