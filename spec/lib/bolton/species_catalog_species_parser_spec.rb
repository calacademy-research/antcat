require 'spec_helper'


describe Bolton::SpeciesCatalog do
  before do
    @species_catalog = Bolton::SpeciesCatalog.new
  end

  describe "Parsing species" do

    it "should handle a normal species" do
      @species_catalog.parse(%{
<b><i><span style='color:red'>brevicornis</span></i></b><i>. Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also: Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.
      }).should == {:type => :species, :name => 'brevicornis', :status => 'valid'}
    end

    describe "Unavailable species" do

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

    describe "fossil" do

      it "should handle a normal fossil species" do
        @species_catalog.parse(%{
*<b><i><span style='color:red'>poinari</span></i></b><i>. *Acanthognathus poinari</i> Baroni Urbani, in Baroni Urbani &amp; De Andrade, 1994: 41, figs. 20, 21, 26, 27 (q.) DOMINICAN AMBER (Miocene). See also: Bolton, 2000: 17.
        }).should == {:type => :species, :name => 'poinari', :fossil => true, :status => 'valid'}
      end

      it "should handle a fossil species where the asterisk is explicitly black" do
        @species_catalog.parse(%{
<span style="color:black">*</span><b><i><span style="color:red">ucrainica</span></i></b><i><span style="color:black">. *Oligomyrmex ucrainicus</span></i><span> Dlussky, in Dlussky &amp; Perkovsky, 2002: 15, fig. 5 (q.) UKRAINE (Rovno Amber). </span>Combination in <i>Carebara</i>: <b>new combination (unpublished).</b><span style="color:black"><p></p></span>
        }).should == {:type => :species, :name => 'ucrainica', :fossil => true, :status => 'valid'}
      end

      it "should handle a fossil species with the formatting tags in another order" do
        @species_catalog.parse(%{
  <i>*<b><span style="color:red">groehni</span></b>. *Amblyopone groehni</i> Dlussky, 2009: 1046, figs. 2a,b (w.) BALTIC AMBER (Eocene).
        }).should == {:type => :species, :name => 'groehni', :fossil => true, :status => 'valid'}
      end

      it "should handle a fossil species with the formatting tags in yet another order" do
        @species_catalog.parse(%{
<b><i>*<span style="color:red">cantalica</span>. </i></b><i>*Formica cantalica</i> Piton, in Piton &amp; Théobald, 1935: 68, pl. 1, fig. 10 (m.?) FRANCE (Mio-Pliocene).
        }).should == {:type => :species, :name => 'cantalica', :fossil => true, :status => 'valid'}
      end

    end
    describe "homonyms" do

      it "should handle an unresolved junior homonym species" do
        @species_catalog.parse(%{
<b><i><span style="color:maroon">bidentatum</span></i></b><i>. Monomorium bidentatum</i> Mayr, 1887: 616 (w.q.) CHILE. Snelling, 1975: 5 (m.); Wheeler, G.C. &amp; Wheeler, J. 1980: 533 (l.). Combination in <i>Monomorium (Notomyrmex</i>): Emery, 1922e: 169; in <i>Notomyrmex</i>: Kusnezov, 1960b: 345; in <i>Nothidris</i>: Ettershank, 1966: 107; in <i>Antichthonidris</i>: Snelling, 1975: 6; in <i>Monomorium</i>: Fernández, 2007b: 132. Senior synonym of <i>piceonigrum</i>: Kusnezov, 1960b: 345. See also: Kusnezov, 1949a: 431. [Note. If the dubious combination of <i>bidentata</i> Smith, F. in <i>Monomorium</i> (above) is correct then <i>bidentatum</i> Mayr, 1887 becomes an <b>unresolved junior secondary homonym</b> of <i>bidentata</i> Smith, F. 1858.]
        }).should == {:type => :species, :name => 'bidentatum', :status => 'unresolved_homonym'}
      end

      it "should handle an unresolved junior secondary homonym" do
        @species_catalog.parse(%{
<b><i><span style="color:#984806">flavum</span></i></b>. <i>Tetramorium flavum</i> Chang &amp; He, 2001a: 2, figs. 1, 2, 16 (w.) CHINA. [<b>Unresolved junior secondary homonym</b> of <i>flavus</i> Donisthorpe, below.]
        }).should == {:type => :species, :name => 'flavum', :status => 'unresolved_homonym'}
      end

      it "should recognize a unresolved junior primary homonym" do
        @species_catalog.parse(%{
*<b><i><span style="color:maroon">major</span></i></b><i>. *Solenopsis major</i> Théobald, 1937b: 201, pl. 4, fig. 16; pl. 14, fig. 4 (m.) FRANCE (Oligocene). [<b>Unresolved junior primary homonym</b> of <i>major</i> Forel, above.]
        }).should == {:type => :species, :name => 'major', :status => 'unresolved_homonym', :fossil => true}
      end
    end

    describe "unidentifiable" do

      it "should handle an unidentifiable species" do
        @species_catalog.parse(%{
<i><span style="color:green">bidentata</span></i>. <i>Myrmica bidentata</i> Smith, F. 1858b: 124 (w.) INDIA. [Bingham, 1903: 212 suggests that this may belong in <i>Solenopsis</i>.] <b>Unidentifiable to genus</b>; <i>incertae sedis</i> in <i>Myrmica</i>: Bolton, 1995b: 277. Combination in <i>Monomorium</i>: Radchenko &amp; Elmes, 2001: 238. [Note. Combination in <i>Monomorium</i> is unconvincing; see note under <i>bidentatum</i> Mayr, below.]
        }).should == {:type => :species, :name => 'bidentata', :status => 'unidentifiable'}
      end

      it "should handle an ichnospecies where the italics include the binomial" do
        @species_catalog.parse(%{
*<i><span style="color:green">kuenzelii</span>. *Attaichnus kuenzelii</i> Laza, 1982: 112, figs. ARGENTINA (ichnospecies).
        }).should == {:type => :species, :name => 'kuenzelii', :status => 'unidentifiable', :fossil => true}
      end

      it "should handle another unidentifiable species" do
        @species_catalog.parse(%{
<b><i><span style="color:green">audouini</span></i></b><i>. Condylodon audouini</i> Lund, 1831a: 132 (w.) BRAZIL. Member of family Mutillidae?: Swainson &amp; Shuckard, 1840: 173; combination in <i>Pseudomyrma</i>: Dalla Torre, 1893: 56; member of subfamily Ponerinae?: Emery, 1921f: 28 (footnote); <i>incertae sedis</i> in Ponerinae: Ward, 1990: 471. <b>Unidentifiable taxon</b>.
        }).should == {:type => :species, :name => 'audouini', :status => 'unidentifiable'}
      end

      it "should handle an unidentifiable species that's not 'green'" do
        @species_catalog.parse(%{
<i><span style="color:#009644">montaniformis</span>. Formica rufibarbis</i> var. <i>montaniformis</i> Kuznetsov-Ugamsky, 1929b: 39 (w.) DAGHESTAN. Junior synonym of <i>glauca</i>: Dlussky, 1967a: 74 (misspelled as <i>montanoides</i>). <b>Unidentifiable taxon</b>: Seifert &amp; Schultz, 2009: 272.
        }).should == {:type => :species, :name => 'montaniformis', :status => 'unidentifiable'}
      end

      it "should handle an unidentifiable species that's not 'green'" do
        @species_catalog.parse(%{
*<b><i><span style="color:green">tabanifluviensis</span></i></b><i>. *Myrmeciites (?) tabanifluviensis</i> Archibald, Cover &amp; Moreau, 2006: 502, figs. 15, 16O (indeterminate) CANADA (Eocene).
        }).should == {:type => :species, :name => 'tabanifluviensis', :status => 'unidentifiable', :fossil => true}
      end

      it "should handle another kind of green for unidentifiable species" do
        @species_catalog.parse(%{
*<i><span style="color:#009900">miegi</span>. *Gesomyrmex miegi</i> Théobald, 1937b: 211, pl. 14, figs. 22, 23 (q.m.) FRANCE (Oligocene). <b>Unidentifiable taxon</b>, <i>incertae sedis</i> in Formicidae: Dlussky, Wappler &amp; Wedmann, 2009: 14.
        }).should == {:type => :species, :name => 'miegi', :status => 'unidentifiable', :fossil => true}
      end

      it "should handle an unidentifiable species in an unidentifiable genus" do
        @species_catalog.parse(%{
<i><span style="color:green">chevrolatii</span></i> Romand, 1846; see under <i><span style="color:green">FORMILA</span></i>.
        }).should == {:type => :species, :name => 'chevrolatii', :status => 'unidentifiable'}
      end

    end

    describe "unavailable species" do

      it "should recognize an unavailable species" do
        @species_catalog.parse(%{
<i><span style="color:purple">umbrata</span></i>. <i>Sima (Tetraponera) bifoveolata</i> st. <i>maculifrons</i> var. <i>umbrata</i> Santschi, 1929c: 98 (w.) ALGERIA<b>.</b> <b>Unavailable name</b> (Ward, 1990: 489.).
        }).should == {:type => :species, :name => 'umbrata', :status => 'unavailable'}
      end

      it "should recognize a different color purple" do
        @species_catalog.parse(%{
<i><span style="color:#7030A0">maculata</span>. Tapinoma maculata</i> Clouse, 2007b: 208. <i>Nomen nudum</i>.
        }).should == {:type => :species, :name => 'maculata', :status => 'unavailable'}
      end

    end
  end

  describe "synonyms" do

    it "should handle a species synonym" do
      @species_catalog.parse(%{
<i><span style='color:black'>dyak.</span> Acanthomyrmex dyak</i> Wheeler, W.M. 1919e: 86 (s.w.) BORNEO. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.
      }).should == {:type => :species, :name => 'dyak', :status => 'synonym'}
    end

    it "should handle a species synonym with an author" do
      @species_catalog.parse(%{
<i>aurea </i>Forel, 1913; see under <b><i>HETEROPONERA</i></b>.
      }).should == {:type => :species, :name => 'aurea', :status => 'synonym'}
    end

    it "should handle a species synonym with an author without comma before year" do
      @species_catalog.parse(%{
*<i>glaesarius</i> Wheeler, W.M. 1915; see under <b><i>TEMNOTHORAX</i></b>.
      }).should == {:type => :species, :name => 'glaesarius', :status => 'synonym', :fossil => true}
    end

    it "should handle an italicized fossil synonym" do
      @species_catalog.parse(%{
*<i>berendti</i> Mayr, 1868; see under <b><i>STENAMMA</i></b>.
      }).should == {:type => :species, :name => 'berendti', :status => 'synonym', :fossil => true}
    end

    it "should handle a synonym where the italics were left off" do
      @species_catalog.parse(%{
dimidiata Forel, 1911: see under <b><i>ACROMYRMEX</i></b>.
      }).should == {:type => :species, :name => 'dimidiata', :status => 'synonym'}
    end

    it "should handle fossil synonym in a fossil genus" do
      @species_catalog.parse(%{
*<i>affinis</i> Heer, 1849; see under *<b><i>PONEROPSIS</i></b>.
      }).should == {:type => :species, :name => 'affinis', :status => 'synonym', :fossil => true}
    end

    it "should handle italicized asterisk" do
      @species_catalog.parse(%{
<i>*pygmaea</i> Mayr, 1868; see under <b><i>NYLANDERIA</i></b>.
      }).should == {:type => :species, :name => 'pygmaea', :status => 'synonym', :fossil => true}
    end

    it "should handle nonfossil with binomial inside italics" do
      @species_catalog.parse(%{
<i>asili. Promyopias asili</i> Crawley, 1916a: 30, fig. (q.) MALAWI. Combination in <i>Pseudoponera</i> (<i>Promyopias</i>): Wheeler, W.M. 1922a: 779. Junior synonym of <i>silvestrii</i>: Brown, 1963: 10.
      }).should == {:type => :species, :name => 'asili', :status => 'synonym'}
    end

    it "should handle when the species name and the binomial are both within the same <i> tag" do
      @species_catalog.parse(%{
<i>crassa. Acanthoponera crassa</i> Brown, 1958g: 255, fig. 10 (w.) ECUADOR. Junior synonym of <i>minor</i>: Kempf &amp; Brown, 1968: 90.
      }).should == {:type => :species, :name => 'crassa', :status => 'synonym'}
    end

    it "should handle a see-under species with genus in brackets" do
      @species_catalog.parse(%{
*<i>rugosostriata</i> Mayr, 1868 [<i>Macromischa</i>]; see under *<b><i>EOCENOMYRMA</i></b>.
      }).should == {:type => :species, :name => 'rugosostriata', :status => 'synonym', :fossil => true}
    end

    it "should handle a see-under species with stuff after the referent" do
      @species_catalog.parse(%{
*<i>pusillus</i> Wheeler, W.M. 1915h: 142; see under *<i>pumilus</i>, above.
      }).should == {:type => :species, :name => 'pusillus', :status => 'synonym', :fossil => true}
    end

    it "should handle it when the whole thing is enclosed in black" do
      @species_catalog.parse(%{
<span style="color:black">*<i>pilosula</i> De Andrade, in Baroni Urbani & De Andrade, 2007; see under <b><i>PYRAMICA</i></b>.</span>
      }).should == {:type => :species, :name => 'pilosula', :status => 'synonym', :fossil => true}
    end

    it "should handle a multi-author citation" do
      @species_catalog.parse(%{
*<i>elevatus. *Exocryptocerus elevatus</i> Vierbergen & Scheven, 1995: 160, fig. 2 (w.) DOMINICAN AMBER (Miocene). Junior synonym of *<i>serratus</i>: De Andrade &amp; Baroni Urbani, 1999: 522.
      }).should == {:type => :species, :name => 'elevatus', :status => 'synonym', :fossil => true}
    end

    it "should handle a subgenus in the binomial" do
      @species_catalog.parse(%{
*<i>antiqua. *Formica (Serviformica) antiqua</i> Dlussky, 1967b: 82, fig. 1 (w.) BALTIC AMBER (Eocene). Junior synonym of *<i>flori</i>: Dlussky, 2002a: 292.
      }).should == {:type => :species, :name => 'antiqua', :status => 'synonym', :fossil => true}
    end

    it "should handle a spacerun and a space at the beginning" do
      @species_catalog.parse(%{
<i><span style="mso-spacerun: yes"> </span>longiceps. Pogonomyrmex brevibarbis</i> st. <i>longiceps</i> Santschi, 1917f: 277 (w.) ARGENTINA. Junior synonym of <i>silvestrii</i>: Kusnezov, 1951a: 250.
      }).should == {:type => :species, :name => 'longiceps', :status => 'synonym'}
    end

    it "should handle this" do
      @species_catalog.parse(%{
*<i><span style="color:black">eocenica</span>. *Eoformica eocenica</i> Cockerell, 1921: 38, fig. 9, pl. 8, fig. 11 (m.) U.S.A. (Eocene). Junior synonym of *<i>pinguis</i>: Carpenter, 1930: 17.
      }).should == {:type => :species, :name => 'eocenica', :status => 'synonym', :fossil => true}
    end

  end
end
