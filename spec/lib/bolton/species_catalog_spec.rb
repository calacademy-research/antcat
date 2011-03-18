require 'spec_helper'

describe Bolton::SpeciesCatalog do
  before do
    @species_catalog = Bolton::SpeciesCatalog.new
  end

  describe "importing files" do
    it "should process them in alphabetical order (not counting extension), so the three Camponotus files get processed in the right order" do
      File.should_receive(:read).with('NGC-Spst-tet.htm').ordered.and_return ''
      File.should_receive(:read).with('NGC-Sptet.htm').ordered.and_return ''
      File.should_receive(:read).with('NGC-Sptet-z.htm').ordered.and_return ''
      @species_catalog.import_files ['NGC-Spst-tet.htm', 'NGC-Sptet-z.htm', 'NGC-Sptet.htm']
    end
  end

  describe 'parsing the file as a whole' do
    it 'should complain bitterly if file is obviously not a species catalog' do
     contents = %{<html><body> <div><p>Foo</p></div> </body></html>}
     Progress.should_receive(:error).with("parse failed on: 'Foo'")
     @species_catalog.import_html contents
    end

    it "should parse a header + see-under + genus-section without complaint" do
      contents = make_contents %{
<p><i>ACANTHOLEPIS</i>: see under <b><i>LEPISIOTA</i></b>.</p> <p><o:p>&nbsp;</o:p></p>

<p><b><i><span style='color:red'>ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)</p>
<p><b><i><span style='color:red'>basispinosus</span></i></b><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p> <p><o:p>&nbsp;</o:p></p>

<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>anguliceps</span></i></b><i>.  Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck Archipelago). Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p>
<p><b><i><span style='color:red'>angusta</span></i></b><i>.  Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.  Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p> <p>&nbsp;</p>

<p><b><i><span style="color:red">TETRAMORIUM</span></i></b></p>
<p>*<b><i><span style='color:red'>poinari</span></i></b><i>. *Acanthognathus poinari</i> Baroni Urbani, in Baroni Urbani &amp; De Andrade, 1994: 41, figs. 20, 21, 26, 27 (q.) DOMINICAN AMBER (Miocene). See also: Bolton, 2000: 17.</p>
      }

      Factory :genus, :name => 'Acanthomyrmex', :subfamily => nil, :tribe => nil
      Factory :genus, :name => 'Anonychomyrma', :subfamily => nil, :tribe => nil
      Factory :genus, :name => 'Tetramorium', :subfamily => nil, :tribe => nil

      Progress.should_not_receive(:error)

      @species_catalog.import_html contents

      Taxon.count.should == 7

      acanthomyrmex = Genus.find_by_name('Acanthomyrmex')
      acanthomyrmex.should_not be_nil
      acanthomyrmex.fossil.should_not be_true

      basispinosus = acanthomyrmex.species.find_by_name('basispinosus')
      basispinosus.fossil.should_not be_true
      basispinosus.taxonomic_history.should == 
%{<p><b><i><span style="color:red">basispinosus</span></i></b><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>}

      tetramorium = Genus.find_by_name('Tetramorium')
      tetramorium.should_not be_invalid
      poinari = tetramorium.species.find_by_name('poinari')
      poinari.fossil.should be_true
    end

    it "should link species to existing genera" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)</p>
<p><b><i><span style='color:red'>basispinosus</span></i></b><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
      }

      Progress.should_not_receive(:error)

      Factory :genus, :name => 'Acanthomyrmex', :subfamily => nil, :tribe => nil
      @species_catalog.import_html contents

      Taxon.count.should == 2

      acanthomyrmex = Genus.find_by_name('Acanthomyrmex')
      acanthomyrmex.should_not be_nil
      basispinosus = acanthomyrmex.species.find_by_name('basispinosus')
      basispinosus.genus.should == acanthomyrmex
    end

    it "should complain if a genus doesn't already exist" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)</p>
<p><b><i><span style='color:red'>basispinosus</span></i></b><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
      }

      Progress.should_receive(:error).with("Genus 'Acanthomyrmex' did not exist")
      @species_catalog.import_html contents
    end

    it "should save statuses correctly" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p> <i><span style='color:purple'>basispinosus</span></i><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
      }

      @species_catalog.import_html contents
      Species.find_by_name('basispinosus').should be_unavailable
    end

    it "should save subspecies correctly" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p> <p>#<b><i><span style='color:blue'>v-nigra</span></i></b><i>.  Crematogaster chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
      }

      @species_catalog.import_html contents
      Species.find_by_name('v-nigra').should be_nil
    end

    it "should skip by subspecies and notes" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>anguliceps</span></i></b><i>.  Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck Archipelago). Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p>
<p>#<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.</p>
<p><span style="color:black">[Note. All <i>Colobostruma</i> taxa with combination in <i>Epopostruma</i>, <i>sensu</i> Baroni Urbani &amp; De Andrade, 2007: 97-98.]</span></p>
<p><b><i><span style='color:red'>angusta</span></i></b><i>.  Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.  Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p>
      }
      Factory :genus, :name => 'Anonychomyrma'

      Progress.should_not_receive :error
      @species_catalog.import_html contents
    end
  end


  describe "parsing a note" do
    it "should work" do
      @species_catalog.parse(%{<span style="color:black">[Note. All <i>Colobostruma</i> taxa with combination in <i>Epopostruma</i>, <i>sensu</i> Baroni Urbani &amp; De Andrade, 2007: 97-98.]</span>}).should == {:type => :note}
    end
    it "should parse 'Notes' as a note" do
      @species_catalog.parse(%{
[Notes. (i) The original spelling <i>Crematogaster</i> is used throughout, the incorrect subsequent spelling <i><span style="color:purple">Cremastogaster</span></i> is ignored; see catalogue of genus-group names. (ii) The spurious paper by Soulié &amp; Dicko, 1965: 85, is ignored. This publication merely repeats, inaccurately, the Wheeler, W.M. 1922a: 828 catalogue of Afrotopical <i>Crematogaster</i>, but treats the subgenera as genera; see catalogue of genus-group names.]
      }).should == {:type => :note}
    end
  end

  def make_contents content
    %{
<html> <head> <title>CATALOGUE OF SPECIES-GROUP TAXA</title> </head>
<body>
<div class=Section1>
<p><b>CATALOGUE OF SPECIES-GROUP TAXA<o:p></o:p></b></p>
<p><o:p>&nbsp;</o:p></p>
<p><o:p>&nbsp;</o:p></p>
      #{content}
<p><o:p>&nbsp;</o:p></p>
</div> </body> </html>
    }
  end

end
