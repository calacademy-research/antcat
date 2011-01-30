require 'spec_helper'

describe Bolton::SpeciesCatalog do
  before do
    @species_catalog = Bolton::SpeciesCatalog.new
  end

  describe "parsing species" do

    it "should handle a normal species" do
      @species_catalog.parse(%{
<b><i><span style='color:red'>brevicornis</span></i></b><i>. Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also: Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.
      }).should == {:type => :species, :name => 'brevicornis'}
    end

    describe "fossil" do

      it "should handle a normal fossil species" do
        @species_catalog.parse(%{
*<b><i><span style='color:red'>poinari</span></i></b><i>. *Acanthognathus poinari</i> Baroni Urbani, in Baroni Urbani &amp; De Andrade, 1994: 41, figs. 20, 21, 26, 27 (q.) DOMINICAN AMBER (Miocene). See also: Bolton, 2000: 17.
        }).should == {:type => :species, :name => 'poinari', :fossil => true}
      end

      it "should handle a fossil species where the asterisk is explicitly black" do
        @species_catalog.parse(%{
<span style="color:black">*</span><b><i><span style="color:red">ucrainica</span></i></b><i><span style="color:black">. *Oligomyrmex ucrainicus</span></i><span> Dlussky, in Dlussky &amp; Perkovsky, 2002: 15, fig. 5 (q.) UKRAINE (Rovno Amber). </span>Combination in <i>Carebara</i>: <b>new combination (unpublished).</b><span style="color:black"><p></p></span>
        }).should == {:type => :species, :name => 'ucrainica', :fossil => true}
      end

      it "should handle a fossil species with the formatting tags in another order" do
        @species_catalog.parse(%{
  <i>*<b><span style="color:red">groehni</span></b>. *Amblyopone groehni</i> Dlussky, 2009: 1046, figs. 2a,b (w.) BALTIC AMBER (Eocene).
        }).should == {:type => :species, :name => 'groehni', :fossil => true}
      end

    end

    describe "unresolved junior homonym" do

      it "should handle an unresolved junior homonym species" do
        @species_catalog.parse(%{
<b><i><span style="color:maroon">bidentatum</span></i></b><i>. Monomorium bidentatum</i> Mayr, 1887: 616 (w.q.) CHILE. Snelling, 1975: 5 (m.); Wheeler, G.C. &amp; Wheeler, J. 1980: 533 (l.). Combination in <i>Monomorium (Notomyrmex</i>): Emery, 1922e: 169; in <i>Notomyrmex</i>: Kusnezov, 1960b: 345; in <i>Nothidris</i>: Ettershank, 1966: 107; in <i>Antichthonidris</i>: Snelling, 1975: 6; in <i>Monomorium</i>: Fernández, 2007b: 132. Senior synonym of <i>piceonigrum</i>: Kusnezov, 1960b: 345. See also: Kusnezov, 1949a: 431. [Note. If the dubious combination of <i>bidentata</i> Smith, F. in <i>Monomorium</i> (above) is correct then <i>bidentatum</i> Mayr, 1887 becomes an <b>unresolved junior secondary homonym</b> of <i>bidentata</i> Smith, F. 1858.]
        }).should == {:type => :species, :name => 'bidentatum', :unresolved_junior_homonym => true}
      end

      it "should handle another unresolved junior homonym species" do
        @species_catalog.parse(%{
  #<b><i><span style="color:maroon">brunneus</span></i></b><i>. Atta (Acromyrmex) subterranea</i> var. <i>brunnea</i> Forel, 1912e: 181 (w.q.m.) BRAZIL. [First available use of <i>Atta (Acromyrmex) coronata</i> subsp. <i>subterranea</i> var. <i>brunnea</i> Forel, 1911c: 291; unavailable name.] [<b>Unresolved junior primary homonym</b> of <i>Atta brunnea</i> Patton, 1894: 618 (now in <i>Odontomachus</i>).] Combination in <i>Acromyrmex</i>: Luederwaldt, 1918: 39. Currently subspecies of <i>subterraneus</i>: Gonçalves, 1961: 167; Kempf, 1972a: 15.
        }).should == {:type => :subspecies, :name => 'brunneus', :unresolved_junior_homonym => true}
      end

    end

    describe "unidentifiable" do

      it "should handle an unidentifiable species" do
        @species_catalog.parse(%{
<i><span style="color:green">bidentata</span></i>. <i>Myrmica bidentata</i> Smith, F. 1858b: 124 (w.) INDIA. [Bingham, 1903: 212 suggests that this may belong in <i>Solenopsis</i>.] <b>Unidentifiable to genus</b>; <i>incertae sedis</i> in <i>Myrmica</i>: Bolton, 1995b: 277. Combination in <i>Monomorium</i>: Radchenko &amp; Elmes, 2001: 238. [Note. Combination in <i>Monomorium</i> is unconvincing; see note under <i>bidentatum</i> Mayr, below.]
        }).should == {:type => :species, :name => 'bidentata', :unidentifiable => true}
      end

      it "should handle an ichnospecies where the italics include the binomial" do
        @species_catalog.parse(%{
*<i><span style="color:green">kuenzelii</span>. *Attaichnus kuenzelii</i> Laza, 1982: 112, figs. ARGENTINA (ichnospecies).
        }).should == {:type => :species, :name => 'kuenzelii', :unidentifiable => true}
      end

      it "should handle another unidentifiable species" do
        @species_catalog.parse(%{
<b><i><span style="color:green">audouini</span></i></b><i>. Condylodon audouini</i> Lund, 1831a: 132 (w.) BRAZIL. Member of family Mutillidae?: Swainson &amp; Shuckard, 1840: 173; combination in <i>Pseudomyrma</i>: Dalla Torre, 1893: 56; member of subfamily Ponerinae?: Emery, 1921f: 28 (footnote); <i>incertae sedis</i> in Ponerinae: Ward, 1990: 471. <b>Unidentifiable taxon</b>.
        }).should == {:type => :species, :name => 'audouini', :unidentifiable => true}
      end

      it "should handle an unidentifiable species that's not 'green'" do
        @species_catalog.parse(%{
<i><span style="color:#009644">montaniformis</span>. Formica rufibarbis</i> var. <i>montaniformis</i> Kuznetsov-Ugamsky, 1929b: 39 (w.) DAGHESTAN. Junior synonym of <i style="mso-bidi-font-style:normal">glauca</i>: Dlussky, 1967a: 74 (misspelled as <i>montanoides</i>). <b>Unidentifiable taxon</b>: Seifert &amp; Schultz, 2009: 272.
        }).should == {:type => :species, :name => 'montaniformis', :unidentifiable => true}
      end

    end
  end

  describe "subspecies" do

    it "should handle a subspecies" do
      @species_catalog.parse(%{
#<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.
      }).should == {:type => :subspecies, :name => 'ajax'}
    end

    describe "unavailable subspecies" do

      it "should handle an unavailable subspecies" do
        @species_catalog.parse(%{
  <i><span style="color:purple">angustata</span>. Atta (Acromyrmex) moelleri</i> subsp. <i>panamensis</i> var. <i>angustata </i>Forel, 1908b: 41 (w.q.) COSTA RICA. <b>Unavailable name</b> (Bolton, 1995b: 54).
        }).should == {:type => :species, :name => 'angustata', :unavailable => true}
      end

      it "should handle an unavailable subspecies without a binomial" do
        @species_catalog.parse(%{
  <i><span style="color:purple">suturalis</span> </i>Santschi, 1921b: 426 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'suturalis', :unavailable => true}
      end

      it "should handle an unavailable subspecies without a binomial with some spaces" do
        @species_catalog.parse(%{
  <i><span style="color:purple">pseudoxanthus</span> </i> Plateaux, 1981: 64 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'pseudoxanthus', :unavailable => true}
      end

      it "should handle an unavailable subspecies without a binomial with the parentheses before the semicolon" do
        @species_catalog.parse(%{
  <i><span style="color:purple">esmirensis</span></i> Santschi, 1936 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'esmirensis', :unavailable => true}
      end

      it "should handle an unavailable subspecies without a comma before the year" do
        @species_catalog.parse(%{
  <i><span style="color:purple">spinosus</span> </i>Smith, M.R. 1929: 551 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'spinosus', :unavailable => true}
      end

      it "should handle an authors list separated by &'s" do
        @species_catalog.parse(%{
  <i><span style="color:purple">parkeri</span> </i> Espadaler &amp; DuMerle, 1989: 121 (<b>unavailable name</b>); see under <b><i>LEPTOTHORAX</i></b>.
        }).should == {:type => :species, :name => 'parkeri', :unavailable => true}
      end

    end

    describe "fossil subspecies" do

      it "should handle a fossil subspecies" do
        @species_catalog.parse(%{
  *#<b><i><span style="color:blue">minor</span></i></b><i>. *Poneropsis lugubris</i> var. <i>minor</i> Heer, 1867: 21 (m.) CROATIA (Miocene).
        }).should == {:type => :subspecies, :name => 'minor', :fossil => true}
      end

    end

    it "should handle a bold italic subspecies indicator" do
      @species_catalog.parse(%{
<b><i>#<span style="color:blue">aeolia</span></i></b><i>. Oligomyrmex oertzeni</i> var. <i>aeolia</i> Forel, 1911d: 338 (q.m.) TURKEY. Combination in <i>Carebara</i>: <b>new combination (unpublished).</b>
      }).should == {:type => :subspecies, :name => 'aeolia'}
    end

  end

  describe "synonyms" do

    #it "should handle a species synonym" do
      #@species_catalog.parse(%{
#<i><span style='color:black'>dyak.</span> Acanthomyrmex dyak</i> Wheeler, W.M. 1919e: 86 (s.w.) BORNEO. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.
      #}).should == {:type => :species, :name => 'dyak', :synonym => true}
    #end

    #it "should handle a species synonym with an author" do
      #@species_catalog.parse(%{
#<i>aurea </i>Forel, 1913; see under <b><i>HETEROPONERA</i></b>.
      #}).should == {:type => :species, :name => 'aurea', :synonym => true}
    #end

    it "should handle a species synonym with an author without comma before year" do
      @species_catalog.parse(%{
*<i>glaesarius</i> Wheeler, W.M. 1915; see under <b><i>TEMNOTHORAX</i></b>.
      }).should == {:type => :species, :name => 'glaesarius', :synonym => true}
    end


    it "should handle an italicized fossil synonym" do
      @species_catalog.parse(%{
*<i>berendti</i> Mayr, 1868; see under <b><i>STENAMMA</i></b>.
      }).should == {:type => :species, :name => 'berendti', :synonym => true}
    end

    it "should handle a synonym where the italics were left off" do
      @species_catalog.parse(%{
dimidiata Forel, 1911: see under <b><i>ACROMYRMEX</i></b>.
      }).should == {:type => :species, :name => 'dimidiata', :synonym => true}
    end

    it "should handle a synonym where the binomial is inside the italics" do
      @species_catalog.parse(%{
*<i>gracillimus. *Lampromyrmex gracillimus</i> Mayr, 1868c: 95, pl. 5, figs. 97, 98 (w.) BALTIC AMBER (Eocene). [Junior secondary homonym of <i>gracillima</i> Smith, above.] Replacement name: *<i>mayrianum</i> Wheeler, W.M. 1915h: 45. [Combination in error, with <i>Lophomyrmex gracillimus</i> for *<i>Lampromyrmex gracillimus</i>: Dlussky, 1997: 57.]
      }).should == {:type => :species, :name => 'gracillimus', :synonym => true}
    end

    it "should handle fossil synonym in a fossil genus" do
      @species_catalog.parse(%{
*<i>affinis</i> Heer, 1849; see under *<b><i>PONEROPSIS</i></b>.
      }).should == {:type => :species, :name => 'affinis', :synonym => true}
    end

    it "should handle italicized asterisk" do
      @species_catalog.parse(%{
<i>*pygmaea</i> Mayr, 1868; see under <b><i>NYLANDERIA</i></b>.
      }).should == {:type => :species, :name => 'pygmaea', :synonym => true}
    end

    #it "should handle nonfossil with binomial inside italics" do
      #@species_catalog.parse(%{
#<i>asili. Promyopias asili</i> Crawley, 1916a: 30, fig. (q.) MALAWI. Combination in <i>Pseudoponera</i> (<i>Promyopias</i>): Wheeler, W.M. 1922a: 779. Junior synonym of <i>silvestrii</i>: Brown, 1963: 10.
      #}).should == {:type => :species, :name => 'asili', :synonym => true}
    #end

    #it "should handle when the species name and the binomial are both within the same <i> tag" do
      #@species_catalog.parse(%{
#<i>crassa. Acanthoponera crassa</i> Brown, 1958g: 255, fig. 10 (w.) ECUADOR. Junior synonym of <i>minor</i>: Kempf &amp; Brown, 1968: 90.
      #}).should == {:type => :species, :name => 'crassa', :synonym => true}
    #end

    it "should handle a see-under species with genus in brackets" do
      @species_catalog.parse(%{
*<i>rugosostriata</i> Mayr, 1868 [<i>Macromischa</i>]; see under *<b><i>EOCENOMYRMA</i></b>.
      }).should == {:type => :species, :name => 'rugosostriata', :synonym => true}
    end

    it "should handle a see-under species with stuff after the referent" do
      @species_catalog.parse(%{
*<i>pusillus</i> Wheeler, W.M. 1915h: 142; see under *<i>pumilus</i>, above.
      }).should == {:type => :species, :name => 'pusillus', :synonym => true}
    end

    it "should handle it when the whole thing is enclosed in black" do
      @species_catalog.parse(%{
<span style="color:black">*<i>pilosula</i> De Andrade, in Baroni Urbani & De Andrade, 2007; see under <b><i>PYRAMICA</i></b>.</span>
      }).should == {:type => :species, :name => 'pilosula', :synonym => true}
    end

    it "should handle a multi-author citation" do
      @species_catalog.parse(%{
*<i>elevatus. *Exocryptocerus elevatus</i> Vierbergen & Scheven, 1995: 160, fig. 2 (w.) DOMINICAN AMBER (Miocene). Junior synonym of *<i>serratus</i>: De Andrade &amp; Baroni Urbani, 1999: 522.
      }).should == {:type => :species, :name => 'elevatus', :synonym => true}
    end

    it "should handle a subgenus in the binomial" do
      @species_catalog.parse(%{
*<i>antiqua. *Formica (Serviformica) antiqua</i> Dlussky, 1967b: 82, fig. 1 (w.) BALTIC AMBER (Eocene). Junior synonym of *<i>flori</i>: Dlussky, 2002a: 292.
      }).should == {:type => :species, :name => 'antiqua', :synonym => true}
    end

  end
end
