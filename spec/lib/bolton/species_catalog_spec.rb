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

  describe 'parsing the file as a whole' do
    it 'should complain bitterly if file is obviously not a species catalog' do
     contents = %{<html><body> <p>Foo</p> </body></html>}
     Progress.should_receive(:error).with("Parse failed: [Foo]")
     @species_catalog.import_html contents
    end

    it "should parse a header + see-under + genus-section without complaint" do
      contents = make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><i
style='mso-bidi-font-style:normal'>ACANTHOLEPIS</i>: see under <b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'>LEPISIOTA</i></b>.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>basispinosus</span></i></b><i style='mso-bidi-font-style:
normal'>. Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14
(s.w.) INDONESIA (Sulawesi).</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>anguliceps</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck
Archipelago). Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>angusta</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.
Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>
      }

      Progress.should_not_receive(:error)
      @species_catalog.import_html contents
    end

    it "should recover from one species it can't parse and continue with the rest" do
      contents = make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>anguliceps</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck
Archipelago). Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><span>foo</span></p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>angusta</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.
Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>
      }

      Progress.should_receive(:error).once
      @species_catalog.import_html contents
    end

    it "should skip by subspecies" do
      contents = make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ANONYCHOMYRMA</span></i></b> (Indo-Australian, Australia)</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>anguliceps</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex anguliceps</i> Forel, 1901b: 18 (q.m.) NEW GUINEA (Bismarck
Archipelago). Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>

<p>#<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.</p>

<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>angusta</span></i></b><i style='mso-bidi-font-style:normal'>.
Iridomyrmex angustus</i> Stitz, 1911a: 369, fig. 15 (w.) NEW GUINEA.
Combination in <i style='mso-bidi-font-style:normal'>Anonychomyrma</i>:
Shattuck, 1992a: 13.</p>
      }

      Progress.should_not_receive :error
      @species_catalog.import_html contents
    end
  end

  describe "parsing genus see-under heading" do
    it "should recognize a simple see-under" do
      @species_catalog.parse("<i>ACANTHOLEPIS</i>: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a genus with an author" do
      @species_catalog.parse("<i>ACROSTIGMA</i> Emery: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a sub-genus" do
      @species_catalog.parse("<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct genus" do
      @species_catalog.parse("*<i>ACROSIYGMA</i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize a sub-genus" do
      @species_catalog.parse("<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct sub-genus" do
      @species_catalog.parse("*<i>#<span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should recognize an extinct referent" do
      @species_catalog.parse("<i>ACANTHOMYOPS</i>: see under *<b><i>LASIUS</i></b>.").should == {:type => :see_under}
    end
    it "should not freak if there's no period at the end" do
      @species_catalog.parse("<i>AROTROPUS</i>: see under <b><i>AMBLYOPONE</i></b>").should == {:type => :see_under}
    end
    it "should not freak if there's no colon after the referer" do
      @species_catalog.parse("<i>ASKETOGENYS</i> see under <b><i>PYRAMICA</i></b>").should == {:type => :see_under}
    end
    it "should handle space between the referer and the colon" do
      @species_catalog.parse("<i>MACROMISCHOIDES</i> : see under <b><i>TETRAMORIUM</i></b>").should == {:type => :see_under}
    end
    it "should handle an italicized space" do
      @species_catalog.parse("<i>HETEROMYRMEX </i>Wheeler: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    end
    it "should handle an author with initials" do
      @species_catalog.parse("<i>HETEROMYRMEX</i>Wheeler, W.M.: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    end
    it "should handle a year after the author" do
      @species_catalog.parse("*<i>PALAEOMYRMEX</i> Dlussky, 1975: see under *<b><i>DLUSSKYIDRIS</i></b>").should == {:type => :see_under}
    end
    it "should handle a subgenus where the # is outside the italics" do
      @species_catalog.parse(%{#<i><span style="color:blue">ALAOPONE</span></i>: see under <b><i>DORYLUS</i></b>.}).should == 
        {:type => :see_under}
    end
    it "should not simply consider everything with 'see under' in it as a see-under" do
      @species_catalog.parse("*<b>PALAEOMYRMEX</b> Dlussky, 1975: see under").should == {:type => :not_understood}
    end
  end

  describe 'parsing a valid genus header' do
    it "should recognize a valid, extant genus heading" do
      @species_catalog.parse("<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)").should == {:type => :genus, :name => 'Acanthognathus'}
    end
    it "should recognize multiple regions" do
      @species_catalog.parse("<b><i><span style=\"color:red\">ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)").should == {:type => :genus, :name => 'Acanthomyrmex'}
    end
    it "should recognize a valid, fossil genus heading" do
      @species_catalog.parse("*<b><i><span style='color:red'>AFROMYRMA</span></i></b> (Botswana)").should == {:type => :genus, :name => 'Afromyrma', :fossil => true}
    end
    it "should handle when Barry includes a little blank red space" do
      @species_catalog.parse("<b><i><span style='color:red'>ACANTHOPONERA</span></i></b><span style='color:red'> </span>(Neotropical)").should == {:type => :genus, :name => 'Acanthoponera'}
    end
    it "should handle a period after the genus name" do
      @species_catalog.parse(%{*<b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:red">ARCHIPONERA</span></i></b>. (U.S.A.)}).should == {:type => :genus, :name => 'Archiponera', :fossil => true}
    end
    it "should handle a space after the genus name" do
      @species_catalog.parse(%{<b><i><span style="color:red">AUSTROMORIUM </span></i></b>(Australia)}).should == {:type => :genus, :name => 'Austromorium'}
    end
    it "should handle a space after the color" do
      @species_catalog.parse(%{<b><i><span style="color:red">DRYMOMYRMEX</span> </i></b>(Baltic Amber)}).should == {:type => :genus, :name => 'Drymomyrmex'}
    end
    it "should handle a missing paren at the end" do
      @species_catalog.parse(%{<b><i><span style="color:red">LEPTOMYRMEX</span></i></b> (Sulawesi, New Guinea, Australia, New Caledonia}).should == {:type => :genus, :name => 'Leptomyrmex'}
    end
    it "should handle a genus without a region" do
      @species_catalog.parse(%{<b><i><span style="color:red">NYLANDERIA</span></i></b>}).should == {:type => :genus, :name => 'Nylanderia'}
    end
    it "should handle superflous paragraph in its midst" do
      @species_catalog.parse(%{<b><i><span style="color:red">NYLANDERIA<p></p></span></i></b>}).should == {:type => :genus, :name => 'Nylanderia'}
    end
    it "should handle unnecessary blackness and parenthesis" do
      @species_catalog.parse(%{<b><i><span style="color:red">OPAMYRMA</span></i></b><span style="color:black"> (Vietnam)<p></p></span>}).should == {:type => :genus, :name => 'Opamyrma'}
    end
    it "should handle an unidentifiable though valid genus" do
      @species_catalog.parse(%{<b><i><span style='color:green'>CONDYLODON</span></i></b> (Brazil)}).should == {:type => :genus, :name => 'Condylodon'}
    end
  end

  describe "parsing an unidentifiable genus header" do
    it "should handle an ichnotaxon" do
      @species_catalog.parse(%{*<i><span style='color:green'>ATTAICHNUS</span></i> (ichnotaxon)}).should == {:type => :genus, :name => 'Attaichnus', :unidentifiable => true, :fossil => true}
    end
    it "should handle transferred genus" do
      @species_catalog.parse(%{*<i><span style="color:green">PALAEOMYRMEX</span></i> Heer, 1865: transferred to <b><i>HOMOPTERA</i></b>.}).should == {:type => :genus, :name => 'Palaeomyrmex', :unidentifiable => true, :fossil => true}
    end

  end

  describe "parsing a blank line" do
    it "should handle '<p> </p>' (nested empty paragraph)" do
      @species_catalog.parse(%{<p> </p>}).should == {:type => :blank}
    end
    it "should handle a nonbreaking space" do
      @species_catalog.parse(%{<p> </p>}).should == {:type => :blank}
    end
    it "should handle a single nonbreaking space" do
      @species_catalog.parse(%{ }).should == {:type => :blank}
    end
    it "should handle a spacerun" do
      @species_catalog.parse(%{<span style="mso-spacerun: yes"> </span>}).should == {:type => :blank}
    end

  end

  describe "parsing species" do
    it "should handle a normal species" do
      @species_catalog.parse(%{
<b><i><span style='color:red'>brevicornis</span></i></b><i>. Acanthognathus brevicornis</i> Smith, M.R. 1944c: 151 (w.q.) PANAMA. See also: Brown &amp; Kempf, 1969: 94; Bolton, 2000: 16.
      }).should == {:type => :species, :name => 'brevicornis'}
    end
    it "should handle a fossil species" do
      @species_catalog.parse(%{
*<b><i><span style='color:red'>poinari</span></i></b><i>. *Acanthognathus poinari</i> Baroni Urbani, in Baroni Urbani &amp; De Andrade, 1994: 41, figs. 20, 21, 26, 27 (q.) DOMINICAN AMBER (Miocene). See also: Bolton, 2000: 17.
      }).should == {:type => :species, :name => 'poinari', :fossil => true}
    end
    it "should handle a fossil species with the prefix in another order" do
      @species_catalog.parse(%{
<i>*<b><span style="color:red">groehni</span></b>. *Amblyopone groehni</i> Dlussky, 2009: 1046, figs. 2a,b (w.) BALTIC AMBER (Eocene).
      }).should == {:type => :species, :name => 'groehni', :fossil => true}
    end
    it "should handle a non-valid species" do
      @species_catalog.parse(%{
<i><span style='color:black'>dyak.</span> Acanthomyrmex dyak</i> Wheeler, W.M. 1919e: 86 (s.w.) BORNEO. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.
      }).should == {:type => :species, :name => 'dyak', :not_valid => true}
    end
    it "should handle a non-valid species with an author" do
      @species_catalog.parse(%{
<i>aurea </i>Forel, 1913; see under <b><i>HETEROPONERA</i></b>.
      }).should == {:type => :species, :name => 'aurea', :not_valid => true}
    end
    it "should handle when the species name and the binomial are both within the same <i> tag" do
      @species_catalog.parse(%{
<i>crassa. Acanthoponera crassa</i> Brown, 1958g: 255, fig. 10 (w.) ECUADOR. Junior synonym of <i>minor</i>: Kempf &amp; Brown, 1968: 90.
      }).should == {:type => :species, :name => 'crassa', :not_valid => true}
    end

    it "should handle an ichnospecies where the italics include the binomial" do
      @species_catalog.parse(%{
*<i><span style="color:green">kuenzelii</span>. *Attaichnus kuenzelii</i> Laza, 1982: 112, figs. ARGENTINA (ichnospecies).
      }).should == {:type => :species, :name => 'kuenzelii', :not_identifiable => true}
    end

    it "should handle a subspecies" do
      @species_catalog.parse(%{
#<b><i><span style="color:blue">ajax</span></i></b><i>. Atta (Acromyrmex) emilii</i> var. <i>ajax</i> Forel, 1909b: 58 (w.) "GUINEA" (in error; in text Forel states "probablement du Brésil"). Currently subspecies of <i>hystrix</i>: Santschi, 1925a: 358.
      }).should == {:type => :subspecies, :name => 'ajax'}
    end
    it "should handle an unavailable subspecies" do
      @species_catalog.parse(%{
<i><span style="color:purple">angustata</span>. Atta (Acromyrmex) moelleri</i> subsp. <i>panamensis</i> var. <i>angustata </i>Forel, 1908b: 41 (w.q.) COSTA RICA. <b>Unavailable name</b> (Bolton, 1995b: 54).
      }).should == {:type => :species, :name => 'angustata', :not_available => true}
    end
    it "should handle a maroon subspecies" do
      @species_catalog.parse(%{
#<b><i><span style="color:maroon">brunneus</span></i></b><i>. Atta (Acromyrmex) subterranea</i> var. <i>brunnea</i> Forel, 1912e: 181 (w.q.m.) BRAZIL. [First available use of <i>Atta (Acromyrmex) coronata</i> subsp. <i>subterranea</i> var. <i>brunnea</i> Forel, 1911c: 291; unavailable name.] [<b>Unresolved junior primary homonym</b> of <i>Atta brunnea</i> Patton, 1894: 618 (now in <i>Odontomachus</i>).] Combination in <i>Acromyrmex</i>: Luederwaldt, 1918: 39. Currently subspecies of <i>subterraneus</i>: Gonçalves, 1961: 167; Kempf, 1972a: 15.
      }).should == {:type => :subspecies, :name => 'brunneus'}
    end

    describe "synonyms" do
      it "should handle an italicized fossil synonym" do
        @species_catalog.parse(%{
  *<i>berendti</i> Mayr, 1868; see under <b><i>STENAMMA</i></b>.
        }).should == {:type => :species, :synonym => true}
      end
      it "should handle a synonym where the italics were left off" do
        @species_catalog.parse(%{
dimidiata Forel, 1911: see under <b><i>ACROMYRMEX</i></b>.
        }).should == {:type => :species, :synonym => true}
      end
    end
  end

  def make_contents content
    %{
<html> <head> <title>CATALOGUE OF SPECIES-GROUP TAXA</title> </head>
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
