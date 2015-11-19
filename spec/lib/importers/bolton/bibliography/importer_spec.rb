# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Bibliography::Importer do
  before do
    @importer = Importers::Bolton::Bibliography::Importer.new
  end

  def diff a, b
    a.length.times do |i|
      raise i.to_s unless a[i] == b[i]
    end
  end

  it "importing a file should call #import_html" do
   expect(File).to receive(:read).with('file_name').and_return('contents')
   expect(@importer).to receive(:import_html).with('contents')
   @importer.import_files ['file_name']
   expect(Bolton::Reference.all).to be_empty
  end

  describe "importing article references" do
    it "should import an article reference" do
      contents = make_contents "Abe, M. &amp; Smith, D.R. 1991d. The genus-group names of Symphyta and their type
species. <i style='mso-bidi-font-style:normal'>Esakia</i> <b style='mso-bidi-font-weight:
normal'>31</b>: 1-115. [31.vii.1991.]"
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.authors).to eq('Abe, M. & Smith, D.R.')
      expect(reference.citation_year).to eq('1991d')
      expect(reference.year).to eq(1991)
      expect(reference.title).to eq('The genus-group names of Symphyta and their type species')
      expect(reference.journal).to eq('Esakia')
      expect(reference.series_volume_issue).to eq('31')
      expect(reference.pagination).to eq('1-115')
      expect(reference.note).to eq('31.vii.1991')
      expect(reference.reference_type).to eq('ArticleReference')
    end

   it "should handle comma instead of period before note" do
     contents = make_contents "Clark,
J. 1934b. New Australian ants. <i style='mso-bidi-font-style:normal'>Memoirs of
the National Museum, Victoria</i> <b style='mso-bidi-font-weight:normal'>8</b>:
21-47, [(30).ix.1934.]"
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Clark, J.')
     expect(reference.citation_year).to eq('1934b')
     expect(reference.year).to eq(1934)
     expect(reference.title).to eq('New Australian ants')
     expect(reference.journal).to eq("Memoirs of the National Museum, Victoria")
     expect(reference.series_volume_issue).to eq("8")
     expect(reference.pagination).to eq('21-47')
     expect(reference.note).to eq('(30).ix.1934')
   end

   it "should handle italics in an article title" do
     contents = make_contents %s{
Dumpert,
K. 2006. <i style='mso-bidi-font-style:normal'>Camponotus (Karavaievia)
khaosokensis</i> nom. n. proposed as replacement name for <i style='mso-bidi-font-style:
normal'>Camponotus (Karavaievia) hoelldobleri</i> Dumpert, 2006. <i
style='mso-bidi-font-style:normal'>Myrmecologische Nachrichten</i> <b
style='mso-bidi-font-weight:normal'>9</b>: 89. [1.2.1934.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Dumpert, K.')
     expect(reference.citation_year).to eq('2006')
     expect(reference.year).to eq(2006)
     expect(reference.title).to eq("Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006")
     expect(reference.journal).to eq("Myrmecologische Nachrichten")
     expect(reference.series_volume_issue).to eq('9')
     expect(reference.pagination).to eq("89")
     expect(reference.note).to eq('1.2.1934')
   end

   it "should handle a missing note" do
     contents = make_contents %s{
Dumpert,
K. 2006. <i style='mso-bidi-font-style:normal'>Camponotus (Karavaievia)
khaosokensis</i> nom. n. proposed as replacement name for <i style='mso-bidi-font-style:
normal'>Camponotus (Karavaievia) hoelldobleri</i> Dumpert, 2006. <i
style='mso-bidi-font-style:normal'>Myrmecologische Nachrichten</i> <b
style='mso-bidi-font-weight:normal'>9</b>: 89.
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Dumpert, K.')
     expect(reference.citation_year).to eq('2006')
     expect(reference.year).to eq(2006)
     expect(reference.title).to eq("Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006")
     expect(reference.journal).to eq("Myrmecologische Nachrichten")
     expect(reference.series_volume_issue).to eq('9')
     expect(reference.pagination).to eq("89")
     expect(reference.note).to be_nil
   end

   it "should handle missing space after note" do
     contents = make_contents %s{
Arnold, G. 1960a.Aculeate Hymenoptera from the Drakensberg Mountains, Natal. <i
style='mso-bidi-font-style:normal'>Annals of the Natal Museum</i> <b
style='mso-bidi-font-weight:normal'>15</b>: 79-87. [8.xii.1960.]
     }

     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Arnold, G.')
     expect(reference.citation_year).to eq('1960a')
     expect(reference.year).to eq(1960)
     expect(reference.title).to eq("Aculeate Hymenoptera from the Drakensberg Mountains, Natal")
     expect(reference.journal).to eq("Annals of the Natal Museum")
     expect(reference.series_volume_issue).to eq('15')
     expect(reference.pagination).to eq('79-87')
     expect(reference.note).to eq('8.xii.1960')
   end

   it "should handle these extra spans" do
     contents = make_contents %s{
<p><span>Brown, W.L.,Jr. 2010. </span><span>The venom. <i>Martialis</i> <b>50</b>:413-423.</span></p>
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Brown, W.L.,Jr.')
   end

   it "should handle missing space after author" do
     contents = make_contents %s{
Brown, W.L.,Jr.1948a. A new <i style='mso-bidi-font-style:normal'>Stictoponera</i>,
with notes on the genus. <i style='mso-bidi-font-style:normal'>Psyche</i> <b
style='mso-bidi-font-weight:normal'>54</b>: 263-264. [17.ii.1948.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Brown, W.L.,Jr.')
     expect(reference.citation_year).to eq('1948a')
     expect(reference.year).to eq(1948)
     expect(reference.title).to eq('A new Stictoponera, with notes on the genus')
     expect(reference.journal).to eq('Psyche')
     expect(reference.series_volume_issue).to eq('54')
     expect(reference.pagination).to eq('263-264')
     expect(reference.note).to eq('17.ii.1948')
   end

   it "should handle text after volume" do
     contents = make_contents %s{
Brown, W.L.,Jr.1948a. A new <i style='mso-bidi-font-style:normal'>Stictoponera</i>,
with notes on the genus. <i style='mso-bidi-font-style:normal'>Psyche</i> <b
style='mso-bidi-font-weight:normal'>54</b> (1947): 263-264. [17.ii.1948.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Brown, W.L.,Jr.')
     expect(reference.citation_year).to eq('1948a')
     expect(reference.year).to eq(1948)
     expect(reference.title).to eq('A new Stictoponera, with notes on the genus')
     expect(reference.journal).to eq('Psyche')
     expect(reference.series_volume_issue).to eq('54 (1947)')
     expect(reference.pagination).to eq('263-264')
     expect(reference.note).to eq('17.ii.1948')
   end

   it "should handle missing period after year" do
     contents = make_contents %s{
Cole, A.C.,Jr. 1952a A new subspecies of <i style='mso-bidi-font-style:normal'>Trachymyrmex
smithi</i> from New Mexico. <i style='mso-bidi-font-style:normal'>Journal of
the Tennessee Academy of Science</i> <b style='mso-bidi-font-weight:normal'>27</b>:
159-162. [(30).iv.1952.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq('Cole, A.C.,Jr.')
     expect(reference.citation_year).to eq('1952a')
     expect(reference.year).to eq(1952)
     expect(reference.title).to eq('A new subspecies of Trachymyrmex smithi from New Mexico')
     expect(reference.journal).to eq('Journal of the Tennessee Academy of Science')
     expect(reference.series_volume_issue).to eq('27')
     expect(reference.pagination).to eq('159-162')
     expect(reference.note).to eq('(30).iv.1952')
   end

   it "should handle a <span> in the title" do
     contents = make_contents %s{
Dumpert, K., Maschwitz, U. & Weissflog, A. 2006. Description of five new weaver ant species of<span style="mso-spacerun: yes"> </span><i style="mso-bidi-font-style: normal">Camponotus</i> subgenus <i style="mso-bidi-font-style:normal">Karavaievia</i> Emery, 1925 from Malaysia and Thailand, with contribution to their biology, especially to colony foundation. <i style="mso-bidi-font-style:normal">Myrmecologische Nachrichten</i> <b style="mso-bidi-font-weight:normal">8</b>: 69-82.
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expected = 'Description of five new weaver ant species of Camponotus subgenus Karavaievia Emery, 1925 from Malaysia and Thailand, with contribution to their biology, especially to colony foundation'
     actual = reference.title
     diff actual, expected
   end

   it "should handle a colon in the title" do
     contents = make_contents %s{
Douwes, P., Jessen, K. & Buschinger, A. 1988. <i style="mso-bidi-font-style:normal">Epimyrma adlerzi</i> sp. n. from Greece: morphology and life history. <i style="mso-bidi-font-style:normal">Entomologica Scandinavica</i> <b style="mso-bidi-font-weight:normal">19</b>: 239-249. [28.ix.1988.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.title).to eq('Epimyrma adlerzi sp. n. from Greece: morphology and life history')
   end

   it "should handle a series indicator" do
     contents = make_contents %s{
Dupuis, C. 1986. Dates de publication de l'Histoire Naturelle Générale et Particulière des Crustacés et des Insectes (1802-1805) par Latreille dans le "Buffon de Sonnini." <i style="mso-bidi-font-style:normal">Annales de la Société Entomologique de France</i> (N.S.) <b style="mso-bidi-font-weight:normal">22</b>: 205-210. [30.vi.1986.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.series_volume_issue).to eq('(N.S.) 22')
   end

   it "should handle when the bold volume immediately follows the italic title" do
     contents = make_contents %s{
DuBois, M.B. 1998a. The first fossil Dorylinae, with notes on fossil Ecitoninae. <i style="mso-bidi-font-style:normal">Entomological News </i><b style="mso-bidi-font-weight: normal">109</b>: 136-142. [1998.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.title).to eq('The first fossil Dorylinae, with notes on fossil Ecitoninae')
   end

   it "should handle a space after the hyphen in the pagination" do
     contents = make_contents %s{
DuBois, M.B. 1993. What's in a name? A clarification of <i style="mso-bidi-font-style: normal">Stenamma westwoodi, S. debile</i>, and <i style="mso-bidi-font-style: normal">S. lippulum. Sociobiology</i> <b style="mso-bidi-font-weight:normal">21</b>: 299- 334. [(31.xii).1993.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.pagination).to eq('299- 334')
   end

   it "should handle spaces around the hyphen in the pagination" do
     contents = make_contents %s{
Dorow, W.H.O. & Kohout, R.J. 1995. A review of the subgenus <i style="mso-bidi-font-style: normal">Hemioptica</i> Roger of the genus <i style="mso-bidi-font-style:normal">Polyrhachis</i> Fr. Smith with description of a new species. <i style="mso-bidi-font-style: normal">Zoologische Mededelingen</i> <b style="mso-bidi-font-weight:normal">69</b>: 93 - 104. [(31.xii).1995.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.pagination).to eq('93 - 104')
   end

   it "should handle big ol' note at the end" do
     contents = make_contents %s{
Dorow, W.H.O. & Kohout, R.J. 1995. Paleogene ants of the genus <i style="mso-bidi-font-style:normal">Archimyrmex</i> Cockerell, 1923. <i style="mso-bidi-font-style:normal">Paleontological Journal</i> <b style=''>37</b>: 39-47. [English translation of <i style="mso-bidi-font-style:normal">Paleontologicheskii Zhurnal</i> 2003 (No. 1): 40-49.]
     }
     @importer.import_html contents
     reference = Bolton::Reference.first
     expect(reference.authors).to eq("Dorow, W.H.O. & Kohout, R.J.")
     expect(reference.reference_type).to eq('ArticleReference')
     expect(reference.title).to eq('Paleogene ants of the genus Archimyrmex Cockerell, 1923')
     expect(reference.pagination).to eq('39-47')
     expect(reference.note).to eq('English translation of Paleontologicheskii Zhurnal 2003 (No. 1): 40-49')
   end

  end

  it 'should skip over a note' do
    contents = make_contents %s{Note: in publications the following name appears as either Dubovikoff or Dubovikov; the latter is used here throughout.  }
    expect(Importers::Bolton::Bibliography::Importer).not_to receive(:parse)
    @importer.import_html contents
  end

  describe 'importing book references' do
    it "should import a book reference" do
      contents = make_contents "Dixon, F. 1940. <i style='mso-bidi-font-style:normal'>The geology and fossils of the Tertiary and Cretaceous formation of Sussex</i>: 422 pp. London. [(31).xii.1850.]"
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.authors).to eq('Dixon, F.')
      expect(reference.citation_year).to eq('1940')
      expect(reference.year).to eq(1940)
      expect(reference.title).to eq("The geology and fossils of the Tertiary and Cretaceous formation of Sussex")
      expect(reference.pagination).to eq('422 pp.')
      expect(reference.place).to eq('London')
      expect(reference.note).to eq('(31).xii.1850')
      expect(reference.reference_type).to eq('BookReference')
    end

    it "should add the book information to the title" do
      contents = make_contents %s{
  Dumpert, K. 1994. <i style='mso-bidi-font-style:normal'>Das Sozialleben der Ameisen</i>. <b style='mso-bidi-font-weight:normal'>2</b>., neubearbeitete Auflage: 257 pp.  Berlin &amp; Hamburg. [(31.xii).1994.]
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.authors).to eq('Dumpert, K.')
      expect(reference.citation_year).to eq('1994')
      expect(reference.year).to eq(1994)
      expect(reference.title).to eq('Das Sozialleben der Ameisen. 2., neubearbeitete Auflage')
      expect(reference.place).to eq('Berlin & Hamburg')
      expect(reference.pagination).to eq('257 pp.')
      expect(reference.note).to eq('(31.xii).1994')
    end

    it "should handle a subtitle (without italics)" do
      contents = make_contents %s{
  Drury, D. 1773. <i style="mso-bidi-font-style:normal">Illustrations of Natural History</i>. Wherein are exhibited upwards of two hundred and twenty figures of exotic insects. <b style="mso-bidi-font-weight:normal">2</b>: 90 pp. London. [(31.xii).1773.]
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.title).to eq('Illustrations of Natural History. Wherein are exhibited upwards of two hundred and twenty figures of exotic insects. 2')
    end

    it "should handle an edition" do
      contents = make_contents %s{
  Donisthorpe, H. 1927b. <i style="mso-bidi-font-style:normal">British Ants, their life-history and classification</i> (2nd. edition): 436 pp. London. [(31.xii).1927.]
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.title).to eq('British Ants, their life-history and classification (2nd. edition)')
    end

    it "should handle a missing note" do
      contents = make_contents %s{
  Don, W. 2007. <i style="mso-bidi-font-style:normal">Ants of New Zealand</i>: 239 pp. Otago University Press.
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.note).to be_nil
    end

  end

  describe 'importing nested references' do
    it "should work" do
      contents = make_contents %s{
  Dlussky, G.M. & Zabelin, S.I. 1985. Fauna murav'ev Basseina R. Sumbar (Yugo-zapadnyi Kopetdag) (pp. 208-246). In Nechaevaya, N.T. <i style="mso-bidi-font-style: normal">Rastitel'nost i Zhivotnyi Mir Zaladnogo Kopetdaga</i>: 277 pp. Ashkhabad, Ylym. [22.x.1985.]
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.title).to eq("Fauna murav'ev Basseina R. Sumbar (Yugo-zapadnyi Kopetdag)")
      expect(reference.citation_year).to eq("1985")
      expect(reference.pagination).to eq("(pp. 208-246)")
      expect(reference.reference_type).to eq('NestedReference')
    end
  end

  describe "removing italics from a note" do
    it "should work" do
      contents = make_contents %s{
  Abe, M. &amp; Smith, D.R. 1991d. The genus-group names of Symphyta and their type species. <i style='mso-bidi-font-style:normal'>Esakia</i> <b style='mso-bidi-font-weight: normal'>31</b>: 1-115. [English translation of <i style="mso-bidi-font-style:normal">Paleontologicheskii Zhurnal</i> 2003 (No. 1): 40-49.]"
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.reference_type).to eq('ArticleReference')
      expect(reference.note).to eq('English translation of Paleontologicheskii Zhurnal 2003 (No. 1): 40-49')
    end
  end

  describe "importing references where we can't tell what it is" do
    it "should work" do
      contents = make_contents %s{
  Dlussky, G.M. & Perfilieva, K.S. 2003. Paleogene ants of the genus <i style="mso-bidi-font-style:normal">Archimyrmex</i> Cockerell, 1923. <i style="mso-bidi-font-style:normal">Paleontological Journal</i> 37: 39-47. [English translation of <i style="mso-bidi-font-style:normal">Paleontologicheskii Zhurnal</i> 2003 (No. 1): 40-49.]
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.reference_type).to eq('UnknownReference')
      expect(reference.citation_year).to eq('2003')
      expect(reference.title).to eq('Paleogene ants of the genus Archimyrmex Cockerell, 1923. Paleontological Journal 37: 39-47. [English translation of Paleontologicheskii Zhurnal 2003 (No. 1): 40-49.]')
    end
  end

  it "should handle when italicization in the title carries over to journal name" do
    contents = make_contents %s{
<p>Wheeler, G.C. &amp; Wheeler, J. 1991a. The larva of <i>Blepharidatta.<span>&nbsp; </span>Journal of the New York Entomological Society</i> <b>99</b>: 132-137.<span>&nbsp; </span>[14.ii.1991.]</p>
    }
    @importer.import_html contents
    reference = Bolton::Reference.first
    expect(reference.title).to eq('The larva of Blepharidatta')
  end

  describe 'saving the original' do
    it "should simplify the HTML markup" do
      contents = make_contents "Abe, M. &amp; Smith, D.R. 1991d. The genus-group names of Symphyta and their type species. <i style='mso-bidi-font-style:normal'>Esakia</i> <b style='mso-bidi-font-weight: normal'>31</b>: 1-115. [31.vii.1991.]"
      @importer.import_html contents
      expect(Bolton::Reference.first.original).to eq("Abe, M. & Smith, D.R. 1991d. The genus-group names of Symphyta and their type species. <i>Esakia</i> <b>31</b>: 1-115. [31.vii.1991.]")
    end
  end

  describe "Importing" do
    it "should call BoltonReference.import" do
      contents = make_contents "Abe, M. &amp; Smith, D.R. 1991d. The genus. <i>Esakia</i> <b>31</b>: 1-115. [31.vii.1991.]"
      reference = FactoryGirl.create :bolton_reference
      expect(Bolton::Reference).to receive(:import).and_return reference
      @importer.import_html contents
    end
    it "should not clear the import result" do
      seen = FactoryGirl.create :bolton_reference, :import_result => 'added'
      Importers::Bolton::Bibliography::Importer.new
      expect(seen.reload.import_result).to eq('added')
    end

    it "should handle this &nbsp; properly" do
      contents = make_contents %{
<p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>Santschi,
F. 1918d. Sous-genres et synonymies de <i style='mso-bidi-font-style:normal'>Cremastogaster.<span
style="mso-spacerun: yes">&nbsp; </span>Bulletin de la Société Entomologique de
France </i><b style='mso-bidi-font-weight:normal'>1918</b>: 182-185.
[27.viii.1918.]</p>
      }
      @importer.import_html contents
      reference = Bolton::Reference.first
      expect(reference.original).to eq(%{Santschi, F. 1918d. Sous-genres et synonymies de <i>Cremastogaster</i>.<i>  Bulletin de la Société Entomologique de France </i><b>1918</b>: 182-185. [27.viii.1918.]})
    end

  end

  describe "Getting new references and seeing if they exist in AntCat" do
    it "should return nothing if there is nothing" do
      expect(@importer.get_new_references).to eq([])
    end
    it "should return a new reference in Bolton" do
      antcat_reference = FactoryGirl.create :book_reference
      new_bolton_reference = FactoryGirl.create :bolton_reference, import_result: 'added'
      bolton_key = new_bolton_reference.key
      expect(@importer.get_new_references).to eq([new_bolton_reference])
    end
    it "should not return a new reference in Bolton that is already in AntCat", pending: true do
      pending("importers no longer used, kept for reference, currently failing")
      new_bolton_reference = FactoryGirl.create :bolton_reference, import_result: 'added'
      bolton_key = new_bolton_reference.key
      antcat_reference = FactoryGirl.create :book_reference, bolton_key_cache: bolton_key
      expect(@importer.get_new_references).to eq([new_bolton_reference])
    end
    it "should not return a reference that's not new", pending: true do
      pending("importers no longer used, kept for reference, currently failing")
      old_bolton_reference = FactoryGirl.create :bolton_reference, import_result: nil
      bolton_key = old_bolton_reference.key
      antcat_reference = FactoryGirl.create :book_reference, bolton_key_cache: bolton_key
      expect(@importer.get_new_references).to eq([])
    end
  end

  def make_contents content
    "<html>
        <body>
  <p class=MsoNormal align=center style='margin-left:.5in;text-align:center;
  text-indent:-.5in'><b style='mso-bidi-font-weight:normal'>CATALOGUE REFERENCES<o:p></o:p></b></p>
  <p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:-.5in'>#{content}
  </p>
        </body>
      </html>
    "
  end

end
