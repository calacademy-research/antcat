require 'spec_helper'


describe Bolton::SpeciesCatalog do
  before do
    @species_catalog = Bolton::SpeciesCatalog.new
  end

  describe "subspecies" do

    it "should handle a subspecies" do
      @species_catalog.parse(%{
#<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.
      }).should == {:type => :subspecies, :name => 'ajax', :status => 'valid', :species => 'hystrix'}
    end

    it "should handle black and blue" do
      @species_catalog.parse(%{
<b><i><span style="color:black">#</span><span style="color:blue">dagmarae</span></i></b><i><span style="color:blue">. </span><span style="color:black">Myrmica moravica</span></i><span style="color:black"> var. <i>dagmarae</i> Sadil, 1939b: 108 (w.q.m.) CZECHIA.<b><i> </i></b>Currently subspecies of <i>lacustris</i> (because <i>moravica</i> and its senior synonym <i>deplanata</i> are both junior synonyms of <i>lacustris</i>).<p></p></span>
      }).should == {:type => :subspecies, :name => 'dagmarae', :status => 'valid', :species => 'lacustris'}
    end

    it "should handle including the period after the name in the italicization of the binomial" do
      @species_catalog.parse(%{
#<b><i><span style="color:blue">nigra</span></i></b><i>. Crematogaster chiarinii</i> var. <i>nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.
      }).should == {:type => :subspecies, :name => 'nigra', :status => 'valid', :species => 'chiarinii'}
    end

    it "should handle a colorless subspecies" do
      @species_catalog.parse(%{
#<i>emarginatobrunneus. Lasius brunneus</i> var. <i>emarginatobrunneus</i> Ruzsky, 1902d: 17 (w.) RUSSIA (attributed to Forel).
      }).should == {:type => :subspecies, :name => 'emarginatobrunneus', :status => 'valid'}
    end

    it "should handle a period in amongst the end tags" do
      @species_catalog.parse(%{
#<b><i><span style="color:blue">torrei</span></i>.</b><i> Crematogaster sanguinea</i> var. <i>torrei</i> Wheeler, W.M. 1913b: 490 (w.q.) CUBA. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 141.
      }).should == {:type => :subspecies, :name => 'torrei', :status => 'valid'}
    end

    describe "unavailable subspecies" do

      it "should handle an unavailable subspecies" do
        @species_catalog.parse(%{
  <i><span style="color:purple">angustata</span>. Atta (Acromyrmex) moelleri</i> subsp. <i>panamensis</i> var. <i>angustata </i>Forel, 1908b: 41 (w.q.) COSTA RICA. <b>Unavailable name</b> (Bolton, 1995b: 54).
        }).should == {:type => :species, :name => 'angustata', :status => 'unavailable'}
      end

      it "should handle an unavailable subspecies without a binomial" do
        @species_catalog.parse(%{
  <i><span style="color:purple">suturalis</span> </i>Santschi, 1921b: 426 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'suturalis', :status => 'unavailable'}
      end

      it "should handle an unavailable subspecies without a binomial with some spaces" do
        @species_catalog.parse(%{
  <i><span style="color:purple">pseudoxanthus</span> </i> Plateaux, 1981: 64 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'pseudoxanthus', :status => 'unavailable'}
      end

      it "should handle an unavailable subspecies without a binomial with the parentheses before the semicolon" do
        @species_catalog.parse(%{
  <i><span style="color:purple">esmirensis</span></i> Santschi, 1936 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'esmirensis', :status => 'unavailable'}
      end

      it "should handle an unavailable subspecies without a comma before the year" do
        @species_catalog.parse(%{
  <i><span style="color:purple">spinosus</span> </i>Smith, M.R. 1929: 551 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'spinosus', :status => 'unavailable'}
      end

      it "should handle an authors list separated by &'s" do
        @species_catalog.parse(%{
  <i><span style="color:purple">parkeri</span> </i> Espadaler &amp; DuMerle, 1989: 121 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'parkeri', :status => 'unavailable'}
      end

      it "should handle a fossil unavailable species" do
        @species_catalog.parse(%{
*<i><span style="color:purple">cephalica</span>. *Formica cephalica</i> Scudder, 1891: 699, no caste mentioned, BALTIC AMBER. <i>Nomen nudum</i>, attributed to Burmeister. [Name may be based on a misinterpretation. Burmeister, 1831: 1100, does not name a species but mentions that he has a number of ants’ heads (<i>formicae cephalicae</i>) in amber.]
        }).should == {:type => :species, :name => 'cephalica', :status => 'unavailable', :fossil => true}
      end

    end

    describe "fossil subspecies" do

      it "should handle a fossil subspecies" do
        @species_catalog.parse(%{
  *#<b><i><span style="color:blue">minor</span></i></b><i>. *Poneropsis lugubris</i> var. <i>minor</i> Heer, 1867: 21 (m.) CROATIA (Miocene).
        }).should == {:type => :subspecies, :name => 'minor', :fossil => true, :status => 'valid'}
      end

      it "should the subspecies mark before th fossil mark" do
        @species_catalog.parse(%{
#*<b><i><span style="color:blue">neuter</span></i></b><i>. *Formica redtenbacheri</i> subsp. <i>neutra</i> Heer, 1849: 130 (q.?). [Also described as new by Heer, 1850: 130.] Combination in <i>Lasius</i>: Bolton, 1995b: 224 [as <i>redtenbacheri</i> referred to <i>Lasius</i> by Mayr, 1867b: 54].
        }).should == {:type => :subspecies, :name => 'neuter', :fossil => true, :status => 'valid'}
      end

    end

    it "should handle a bold italic subspecies indicator" do
      @species_catalog.parse(%{
<b><i>#<span style="color:blue">aeolia</span></i></b><i>. Oligomyrmex oertzeni</i> var. <i>aeolia</i> Forel, 1911d: 338 (q.m.) TURKEY. Combination in <i>Carebara</i>: <b>new combination (unpublished).</b>
      }).should == {:type => :subspecies, :name => 'aeolia', :status => 'valid', :species => 'oertzeni'}
    end

    describe "subspecies homonyms" do
      it "should handle an unresolved junior homonym subspecies" do
        @species_catalog.parse(%{
  #<b><i><span style="color:maroon">brunneus</span></i></b><i>. Atta (Acromyrmex) subterranea</i> var. <i>brunnea</i> Forel, 1912e: 181 (w.q.m.) BRAZIL. [First available use of <i>Atta (Acromyrmex) coronata</i> subsp. <i>subterranea</i> var. <i>brunnea</i> Forel, 1911c: 291; unavailable name.] [<b>Unresolved junior primary homonym</b> of <i>Atta brunnea</i> Patton, 1894: 618 (now in <i>Odontomachus</i>).] Combination in <i>Acromyrmex</i>: Luederwaldt, 1918: 39. Currently subspecies of <i>subterraneus</i>: Gonçalves, 1961: 167; Kempf, 1972a: 15.
        }).should == {:type => :subspecies, :name => 'brunneus', :status => 'homonym'}
      end

      it "should handle a fossil unresolved junior homonym subspecies" do
        @species_catalog.parse(%{
*#<b><i><span style="color:maroon">major</span></i></b><i>. *Formica lavateri</i> var. <i>major</i> Heer, 1867: 11, pl. 1, fig. 106 (q.) CROATIA (Miocene). [<b>Unresolved junior primary homonym</b> of <i>major</i> Nylander, 1849: 29, above.]
        }).should == {:type => :subspecies, :name => 'major', :status => 'homonym', :fossil => true}
      end
    end

  end

end
