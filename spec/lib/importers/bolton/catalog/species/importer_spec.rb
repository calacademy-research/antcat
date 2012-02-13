# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Species::Importer.new
  end

  describe "importing files" do
    it "should process them in alphabetical order (not counting extension), so the three Camponotus files get processed in the right order" do
      File.should_receive(:read).with('NGC-Spst-tet.htm').ordered.and_return ''
      File.should_receive(:read).with('NGC-Sptet.htm').ordered.and_return ''
      File.should_receive(:read).with('NGC-Sptet-z.htm').ordered.and_return ''
      @importer.import_files ['NGC-Spst-tet.htm', 'NGC-Sptet-z.htm', 'NGC-Sptet.htm']
    end
  end

  describe 'parsing the file as a whole' do

    it 'should complain bitterly if file is obviously not a species catalog' do
     contents = %{<html><body> <div><p>Foo</p></div> </body></html>}
     lambda {@importer.import_html contents}.should raise_error Citrus::ParseError
    end

    it 'should clear out species and subspecies' do
      Factory :species
      Factory :subspecies
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
      }
      Species.count.should == 0
      Subspecies.count.should == 0
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

      @importer.import_html contents

      Taxon.count.should == 7

      acanthomyrmex = Genus.find_by_name('Acanthomyrmex')
      acanthomyrmex.should_not be_nil
      acanthomyrmex.fossil.should be_false

      basispinosus = acanthomyrmex.species.find_by_name('basispinosus')
      basispinosus.fossil.should be_false
      basispinosus.taxonomic_history.should == 
%{<p><b><i>basispinosus</i></b><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>}

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
      @importer.import_html contents

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
      Progress.should_receive(:error).with "Genus 'Acanthomyrmex' did not exist"
      @importer.import_html contents
    end

    it "should save statuses correctly" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p> <i><span style='color:purple'>basispinosus</span></i><i>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
      }

      @importer.import_html contents
      Species.find_by_name('basispinosus').should be_unavailable
    end

    it "should skip by notes" do
      contents = make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>anguliceps</span></i></b><i>.  Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck Archipelago). Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p>
<p><span style="color:black">[Note. All <i>Colobostruma</i> taxa with combination in <i>Epopostruma</i>, <i>sensu</i> Baroni Urbani &amp; De Andrade, 2007: 97-98.]</span></p>
<p><b><i><span style='color:red'>angusta</span></i></b><i>.  Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.  Combination in <i>Anonychomyrma</i>: Shattuck, 1992a: 13.</p>
      }
      Factory :genus, :name => 'Anonychomyrma'

      Progress.should_not_receive :error
      @importer.import_html contents
    end

    it "should add recombinations" do
      genus = Factory :genus, :name => 'Turneria'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>TURNERIA</span></i></b> </p> 
<p><i>butteli</i> Forel, 1913; see under <b><i>IRIDOMYRMEX</i></b>.</p> 
      }
      species = Species.find_by_genus_id_and_name genus.id, 'butteli'
      species.status.should == 'recombined'
      species.taxonomic_history.should == %{<p><i>butteli</i> Forel, 1913; see under <b><i>IRIDOMYRMEX</i></b>.</p>}
    end

  end

  describe "Subspecies" do
    it "should not be OK if a subspecies is seen but not its species" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii nigra was seen but not its species"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
      }
    end

    it "should not be OK if a species is seen first, then a subspecies is seen, but the species has no subspecies list" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii nigra was seen and created even though it was not in its species's subspecies list"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
      }
    end

    it "should not be OK if a species is seen first, then a subspecies is seen, but the subspecies is not in the species's subspecies list; however, the subspecies should still be created" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii nigra was seen and created even though it was not in its species's subspecies list"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'></span></i>.</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
      }
      Genus.find_by_name('Anonychomyrma').species.find_by_name('chiarinii').subspecies.find_by_name('nigra').should_not be_nil
    end

    it "should be OK if a species is seen first, then a subspecies is seen, which is in the species's list" do
      Factory :genus, :name => 'Anonychomyrma'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>nigra</span></i>.</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
      }
      nigra = Subspecies.find_by_name 'nigra'
      nigra.should_not be_nil
      nigra.species.name.should == 'chiarinii'
      nigra.species.genus.name.should == 'Anonychomyrma'
    end

    it "should be OK if the subspecies is seen first, then the species is seen, and the subspecies is in the species's subspecies list" do
      Factory :genus, :name => 'Anonychomyrma'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>nigra</span></i>.</p>
      }
      Subspecies.find_by_name('nigra').should_not be_nil
    end

    it "should not be OK if the subspecies is seen first, then the species is seen, but the subspecies is not in the species's subspecies list" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii nigra was seen and created even though it was not in its species's subspecies list"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'></span></i>.</p>
      }
    end

    it "should not be OK if a species is seen but a subspecies in its list is not seen" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii fuhrmanii was in its species's subspecies list but was not seen"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>fuhrmanii</span></i>.</p>
      }
    end

    it "should report both errors if there are more than one" do
      Factory :genus, :name => 'Anonychomyrma'
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii nigra was seen and created even though it was not in its species's subspecies list"
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii boxi was in its species's subspecies list but was not seen"
      Progress.should_receive(:error).with "Subspecies Anonychomyrma chiarinii fuhrmanii was in its species's subspecies list but was not seen"
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>
<p><b><i><span style='color:blue'>nigra</span></i></b><i>. Anyonychomyrma chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.</p>
<p><b><i><span style='color:red'>chiarinii</span></i></b><i>. Anyonychomyrma chiarinii</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146. Current subspecies: nominal plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>fuhrmanii, boxi</span></i>.</p>
      }
    end

    it "should create a synonym if it can't find its species, but it exists in another species's subspecies list" do
      Factory :genus, :name => 'Acromyrmex'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ACROMYRMEX</span></i></b><span style='color:red'> </span>(Neotropical, southern Nearctic)</p>
<p><b><i><span style='color:blue'>carli</span></i></b><i>. Acromyrmex lundi</i> subsp. <i>carli</i> Gonçalves, 1961: 152 (w.) MEXICO. [First available use of <i>Acromyrmex lundi</i> st. <i>pubescens</i> var. <i>carli </i>Santschi, 1925a: 385; unavailable name.]</p>
<p><b><i><span style='color:red'>lundii</span></i></b><i>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Current subspecies: nominal plus <i><span style='color:blue'>carli</span></i>.</p>
      }
      carli = Subspecies.find_by_name 'carli'
      lundi = Species.find_by_name 'lundi'
      lundii = Species.find_by_name 'lundii'
      carli.species.should == lundii
      lundi.should be_synonym
      lundi.synonym_of.should == lundii
      lundi.genus.should == lundii.genus
    end

    it "should only create one synonym if two subspecies can't find their species, which are in another species's subspecies list" do
      Factory :genus, :name => 'Acromyrmex'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>ACROMYRMEX</span></i></b><span style='color:red'> </span>(Neotropical, southern Nearctic)</p>
<p><b><i><span style='color:blue'>carli</span></i></b><i>. Acromyrmex lundi</i> subsp. <i>carli</i> Gonçalves, 1961: 152 (w.) MEXICO. [First available use of <i>Acromyrmex lundi</i> st. <i>pubescens</i> var. <i>carli </i>Santschi, 1925a: 385; unavailable name.]</p>
<p><b><i><span style='color:blue'>parallelus</span></i></b><i>. Acromyrmex lundi</i> subsp. <i>parallelus</i> Gonçalves, 1961: 152 (w.) MEXICO. [First available use of <i>Acromyrmex lundi</i> st. <i>pubescens</i> var. <i>carli </i>Santschi, 1925a: 385; unavailable name.]</p>
<p><b><i><span style='color:red'>lundii</span></i></b><i>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Current subspecies: nominal plus <i><span style='color:blue'>carli, parallelus</span></i>.</p>
      }
      Species.count.should == 2
      carli = Subspecies.find_by_name 'carli'
      parallelus = Subspecies.find_by_name 'parallelus'
      lundi = Species.find_by_name 'lundi'
      lundii = Species.find_by_name 'lundii'
      carli.species.should == lundii
      parallelus.species.should == lundii
      lundi.should be_synonym
      lundi.synonym_of.should == lundii
    end

    it "should ignore invalid species when searching for a subspecies list" do
      Factory :genus, :name => 'Vollenhovia'
      @importer.import_html make_contents %{
<p><b><i><span style='color:red'>VOLLENHOVIA</span></i></b> (Old World tropics and subtropics except Africa)</p>
<p><b><i><span style='color:red'>brevicornis</span></i></b><i>. Monomorium brevicorne</i> Emery, 1893e: 203 (w.) INDONESIA (Sumatra).  Combination in <i>Vollenhovia</i>: Emery, 1914f: 406 (footnote). Current subspecies: nominal plus <i style='mso-bidi-font-style: normal'><span style='color:blue'>minuta</span></i>.</p>
<p><i>brevicornis. Vollenhovia brevicornis</i> Emery, 1897d: 560 (w.) NEW GUINEA. [Junior secondary homonym of <i>brevicorne</i> Emery, above.] Replacement name: <i>brachycera</i> Emery, 1914f: 407 (footnote).</p>
<p><b><i><span style='color:blue'>minuta</span></i></b><i>. Vollenhovia brevicornis</i> var. <i>minuta</i> Viehmeyer, 1916a: 129 (w.) WEST MALAYSIA.</p>
      }
      brevicornises = Species.all :conditions => ['name = ?', 'brevicornis']
      brevicornises.count.should == 2
      minuta = Subspecies.find_by_name 'minuta'
      minuta.species.status.should == 'valid'
    end

  end

  describe "parsing a note" do
    it "should work" do
      @importer.parse(%{<span style="color:black">[Note. All <i>Colobostruma</i> taxa with combination in <i>Epopostruma</i>, <i>sensu</i> Baroni Urbani &amp; De Andrade, 2007: 97-98.]</span>}).should == {:type => :note}
    end
    it "should parse 'Notes' as a note" do
      @importer.parse(%{
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
