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
    
    describe "processing a representative sample and making sure they're saved correctly" do
      it 'should work' do
        @genus_catalog.import_html make_content %{
<p>asdfdsfsdf</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

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
style='mso-bidi-font-style:normal'>ACAMATUS</i> [junior homonym, see <i
style='mso-bidi-font-style:normal'>Neivamyrmex</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'><span style='color:purple'>ANCYLOGNATHUS</span></i>
[<i style='mso-bidi-font-style:normal'>Nomen nudum</i>]</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>PROTAZTECA</span></i></b> [<i style='mso-bidi-font-style:
normal'>incertae sedis</i> in Dolichoderinae]</p>
        }

        Genus.count.should == 8

        acromyrmex = Genus.find_by_name 'Acromyrmex'
        acromyrmex.should_not be_fossil
        acromyrmex.subfamily.name.should == 'Myrmicinae'
        acromyrmex.tribe.name.should == 'Attini'
        acromyrmex.should_not be_invalid
        acromyrmex.taxonomic_history.should == %{<p class="MsoNormal" style="margin-left:.5in;text-align:justify;text-indent:-.5in"><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:red">ACROMYRMEX</span></i></b> [Myrmicinae: Attini]</p>}

        attaichnus = Genus.find_by_name 'Attaichnus'
        attaichnus.should be_fossil
        attaichnus.should be_unidentifiable

        acalama = Genus.find_by_name 'Acalama'
        acalama.should_not be_fossil
        acalama.should be_synonym
        acalama.should be_invalid
        acalama.synonym_of.name.should == 'Gauromyrmex'

        ancylognathus = Genus.find_by_name 'Ancylognathus'
        ancylognathus.should_not be_available
        
        protazteca = Genus.find_by_name 'Protazteca'
        protazteca.tribe.name.should == 'incertae_sedis'
        protazteca.subfamily.name.should == 'Dolichoderinae'

        acamatus = Genus.find_by_name 'Acamatus'
        acamatus.should be_homonym
        acamatus.should be_invalid
        acamatus.homonym_of.name.should == 'Neivamyrmex'

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

  describe "saving the result of the parse" do
    it "should not create the genus if the passed-in subfamily isn't valid" do
      lambda {@genus_catalog.save_genus :type => :genus, :name => 'Acalama', :status => :valid, :subfamily => ''}.should raise_error
    end
    it "should not create the genus if the passed-in tribe isn't valid" do
      lambda {@genus_catalog.save_genus :type => :genus, :name => 'Acalama', :status => :valid, :tribe => ''}.should raise_error
    end
    it "should not create the genus if the passed-in synonym_of isn't valid" do
      lambda {@genus_catalog.save_genus :type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => ''}.should raise_error
    end
    it "should not create the genus if the passed-in homonym_of isn't valid" do
      lambda {@genus_catalog.save_genus :type => :genus, :name => 'Acalama', :status => :homonym, :homonym_of => ''}.should raise_error
    end
    it "should set the synonym_of correctly" do
      @genus_catalog.save_genus :type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'
      Taxon.count.should == 2
      acalama = Genus.find_by_name 'Acalama'
      gauromyrmex = Genus.find_by_name 'Gauromyrmex'
      acalama.synonym_of.should == gauromyrmex
      gauromyrmex.synonym_of.should be_nil
    end

    it "should set the homonym_of correctly" do
      @genus_catalog.save_genus :type => :genus, :name => 'Acamatus', :status => :homonym, :homonym_of => 'Neivamyrmex'
      Taxon.count.should == 2
      acamatus = Genus.find_by_name 'Acamatus'
      neivamyrmex = Genus.find_by_name 'Neivamyrmex'
      acamatus.homonym_of.should == neivamyrmex
      neivamyrmex.homonym_of.should be_nil
    end
  end

end
