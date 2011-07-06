require 'spec_helper'

describe Bolton::Catalog::Species::Importer do
  before do
    @importer = Bolton::Catalog::Species::Importer.new
  end

  describe "subspecies" do

    it "should handle a subspecies" do
      @importer.parse(%{
<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.
      }).should == {:type => :subspecies, :name => 'ajax', :status => 'valid', :species => 'hystrix'}
    end

    it "should handle a name with a hyphen after the first letter" do
      @importer.parse(%{
<b><i><span style='color:blue'>v-nigra</span></i></b><i>.  Crematogaster chiarinii</i> var. <i>v-nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.
      }).should == {:type => :subspecies, :name => 'v-nigra', :status => 'valid', :species => 'chiarinii'}
    end

    it "should handle black and blue" do
      @importer.parse(%{
<b><i><span style="color:black"></span><span style="color:blue">dagmarae</span></i></b><i><span style="color:blue">. </span><span style="color:black">Myrmica moravica</span></i><span style="color:black"> var. <i>dagmarae</i> Sadil, 1939b: 108 (w.q.m.) CZECHIA.<b><i> </i></b>Currently subspecies of <i>lacustris</i> (because <i>moravica</i> and its senior synonym <i>deplanata</i> are both junior synonyms of <i>lacustris</i>).<p></p></span>
      }).should == {:type => :subspecies, :name => 'dagmarae', :status => 'valid', :species => 'lacustris'}
    end

    it "should handle including the period after the name in the italicization of the binomial" do
      @importer.parse(%{
<b><i><span style="color:blue">nigra</span></i></b><i>. Crematogaster chiarinii</i> var. <i>nigrum</i> Forel, 1910e: 434: (w.) DEMOCRATIC REPUBLIC OF CONGO. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 146.
      }).should == {:type => :subspecies, :name => 'nigra', :status => 'valid', :species => 'chiarinii'}
    end

    it "should handle a period in amongst the end tags" do
      @importer.parse(%{
<b><i><span style="color:blue">torrei</span></i>.</b><i> Crematogaster sanguinea</i> var. <i>torrei</i> Wheeler, W.M. 1913b: 490 (w.q.) CUBA. Combination in <i>C. (Acrocoelia</i>): Emery, 1922e: 141.
      }).should == {:type => :subspecies, :name => 'torrei', :status => 'valid', :species => 'sanguinea'}
    end

    it "should handle a blue period, like Picasso" do
      @importer.parse(%{
<i><b><span style="color:blue">dallatorrei</span></b><span style="color:blue">.</span> Camponotus alii dallatorrei</i> Özdikmen, 2010a: 520. Replacement name for <i>concolor</i> Dalla Torre, 1893: 221. [Junior primary homonym of <i>concolor</i> Forel, 1891b: 214.]
      }).should == {:type => :subspecies, :name => 'dallatorrei', :status => 'valid', :species => 'alii'}
    end

    it "should handle " do
      @importer.parse(%{
<b><i><span style="color:blue">nigrosubnuda</span></i></b><i>. Crematogaster subnuda nigrosubnuda</i> Özdikmen, 2010c: 990. Replacement name for <i>formosae</i> Wheeler, W.M. 1909d: 336. [Junior primary homonym of <i>formosa</i> Mayr, 1870b: 994.]
      }).should == {:type => :subspecies, :name => 'nigrosubnuda', :status => 'valid', :species => 'subnuda'}
    end

    describe "fossil subspecies" do

      it "should handle a fossil subspecies" do
        @importer.parse(%{
  *<b><i><span style="color:blue">minor</span></i></b><i>. *Poneropsis lugubris</i> var. <i>minor</i> Heer, 1867: 21 (m.) CROATIA (Miocene).
        }).should == {:type => :subspecies, :name => 'minor', :fossil => true, :status => 'valid', :species => 'lugubris'}
      end

    end

    it "should handle a bold italic subspecies indicator" do
      @importer.parse(%{
<b><i><span style="color:blue">aeolia</span></i></b><i>. Oligomyrmex oertzeni</i> var. <i>aeolia</i> Forel, 1911d: 338 (q.m.) TURKEY. Combination in <i>Carebara</i>: <b>new combination (unpublished).</b>
      }).should == {:type => :subspecies, :name => 'aeolia', :status => 'valid', :species => 'oertzeni'}
    end

    it "should handle a blue italicized period" do
      @importer.parse(%{
<b><i><span style="color:blue">dallatorrei</span></i></b><i><span style="color:blue">.</span> Camponotus alii dallatorrei</i> Özdikmen, 2010a: 520. Replacement name for <i>concolor</i> Dalla Torre, 1893: 221. [Junior primary homonym of <i>concolor</i> Forel, 1891b: 214.]
      }).should == {:type => :subspecies, :name => 'dallatorrei', :status => 'valid', :species => 'alii'}
    end


    #describe "subspecies homonyms" do
      #it "should handle an unresolved junior homonym subspecies" do
        #@importer.parse(%{
  #<b><i><span style="color:maroon">brunneus</span></i></b><i>. Atta (Acromyrmex) subterranea</i> var. <i>brunnea</i> Forel, 1912e: 181 (w.q.m.) BRAZIL. [First available use of <i>Atta (Acromyrmex) coronata</i> subsp. <i>subterranea</i> var. <i>brunnea</i> Forel, 1911c: 291; unavailable name.] [<b>Unresolved junior primary homonym</b> of <i>Atta brunnea</i> Patton, 1894: 618 (now in <i>Odontomachus</i>).] Combination in <i>Acromyrmex</i>: Luederwaldt, 1918: 39. Currently subspecies of <i>subterraneus</i>: Gonçalves, 1961: 167; Kempf, 1972a: 15.
        #}).should == {:type => :subspecies, :name => 'brunneus', :status => 'homonym', :species => 'subterraneus'}
      #end

      #it "should handle a fossil unresolved junior homonym subspecies" do
        #@importer.parse(%{
#*<b><i><span style="color:maroon">major</span></i></b><i>. *Formica lavateri</i> var. <i>major</i> Heer, 1867: 11, pl. 1, fig. 106 (q.) CROATIA (Miocene). [<b>Unresolved junior primary homonym</b> of <i>major</i> Nylander, 1849: 29, above.]
        #}).should == {:type => :subspecies, :name => 'major', :status => 'homonym', :fossil => true, :species => 'lavateri'}
      #end

    #end
  end
end
