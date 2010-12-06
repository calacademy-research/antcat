require 'spec_helper'

describe Bolton::Bibliography do
  before do
    @bibliography = Bolton::Bibliography.new 'filename'
  end

  it "importing a file should call #import_html" do
    File.should_receive(:read).with('filename').and_return('contents')
    @bibliography.should_receive(:import_html).with('contents')
    @bibliography.import_file
    Bolton::Reference.all.should be_empty
  end

  describe "importing article references" do
    it "should import an article reference" do
      contents = make_contents "Abe, M. &amp; Smith, D.R. 1991d. The genus-group names of Symphyta and their type
species. <i style='mso-bidi-font-style:normal'>Esakia</i> <b style='mso-bidi-font-weight:
normal'>31</b>: 1-115. [31.vii.1991.]"
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Abe, M. & Smith, D.R.'
      reference.citation_year.should == '1991d'
      reference.year.should == 1991
      reference.title.should == 'The genus-group names of Symphyta and their type species'
      reference.journal.should == 'Esakia'
      reference.series_volume_issue.should == '31'
      reference.pagination.should == '1-115'
      reference.date.should == '31.vii.1991'
      reference.reference_type.should == 'ArticleReference'
    end

    it "should handle comma instead of period before date" do
      contents = make_contents "Clark,
J. 1934b. New Australian ants. <i style='mso-bidi-font-style:normal'>Memoirs of
the National Museum, Victoria</i> <b style='mso-bidi-font-weight:normal'>8</b>:
21-47, [(30).ix.1934.]"
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Clark, J.'
      reference.citation_year.should == '1934b'
      reference.year.should == 1934
      reference.title.should == 'New Australian ants'
      reference.journal.should == "Memoirs of the National Museum, Victoria"
      reference.series_volume_issue.should == "8"
      reference.pagination.should == '21-47'
      reference.date.should == '(30).ix.1934'
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
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dumpert, K.'
      reference.citation_year.should == '2006'
      reference.year.should == 2006
      reference.title.should == "Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006"
      reference.journal.should == "Myrmecologische Nachrichten"
      reference.series_volume_issue.should == '9'
      reference.pagination.should == "89"
      reference.date.should == '1.2.1934'
    end

    it "should handle a missing date" do
      contents = make_contents %s{
Dumpert,
K. 2006. <i style='mso-bidi-font-style:normal'>Camponotus (Karavaievia)
khaosokensis</i> nom. n. proposed as replacement name for <i style='mso-bidi-font-style:
normal'>Camponotus (Karavaievia) hoelldobleri</i> Dumpert, 2006. <i
style='mso-bidi-font-style:normal'>Myrmecologische Nachrichten</i> <b
style='mso-bidi-font-weight:normal'>9</b>: 89.
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dumpert, K.'
      reference.citation_year.should == '2006'
      reference.year.should == 2006
      reference.title.should == "Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006"
      reference.journal.should == "Myrmecologische Nachrichten"
      reference.series_volume_issue.should == '9'
      reference.pagination.should == "89"
      reference.date.should be_nil
    end
    
    it "should handle missing space after date" do
      contents = make_contents %s{
Arnold, G. 1960a.Aculeate Hymenoptera from the Drakensberg Mountains, Natal. <i
style='mso-bidi-font-style:normal'>Annals of the Natal Museum</i> <b
style='mso-bidi-font-weight:normal'>15</b>: 79-87. [8.xii.1960.]
      }

      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Arnold, G.'
      reference.citation_year.should == '1960a'
      reference.year.should == 1960
      reference.title.should == "Aculeate Hymenoptera from the Drakensberg Mountains, Natal"
      reference.journal.should == "Annals of the Natal Museum"
      reference.series_volume_issue.should == '15'
      reference.pagination.should == '79-87'
      reference.date.should == '8.xii.1960'
    end

    it "should handle missing space after author" do
      contents = make_contents %s{
Brown, W.L.,Jr.1948a. A new <i style='mso-bidi-font-style:normal'>Stictoponera</i>,
with notes on the genus. <i style='mso-bidi-font-style:normal'>Psyche</i> <b
style='mso-bidi-font-weight:normal'>54</b>: 263-264. [17.ii.1948.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Brown, W.L.,Jr.'
      reference.citation_year.should == '1948a'
      reference.year.should == 1948
      reference.title.should == 'A new Stictoponera, with notes on the genus'
      reference.journal.should == 'Psyche'
      reference.series_volume_issue.should == '54'
      reference.pagination.should == '263-264'
      reference.date.should == '17.ii.1948'
    end

    it "should handle text after volume" do
      contents = make_contents %s{
Brown, W.L.,Jr.1948a. A new <i style='mso-bidi-font-style:normal'>Stictoponera</i>,
with notes on the genus. <i style='mso-bidi-font-style:normal'>Psyche</i> <b
style='mso-bidi-font-weight:normal'>54</b> (1947): 263-264. [17.ii.1948.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Brown, W.L.,Jr.'
      reference.citation_year.should == '1948a'
      reference.year.should == 1948
      reference.title.should == 'A new Stictoponera, with notes on the genus'
      reference.journal.should == 'Psyche'
      reference.series_volume_issue.should == '54 (1947)'
      reference.pagination.should == '263-264'
      reference.date.should == '17.ii.1948'
    end

    it "should handle missing period after year" do
      contents = make_contents %s{
Cole, A.C.,Jr. 1952a A new subspecies of <i style='mso-bidi-font-style:normal'>Trachymyrmex
smithi</i> from New Mexico. <i style='mso-bidi-font-style:normal'>Journal of
the Tennessee Academy of Science</i> <b style='mso-bidi-font-weight:normal'>27</b>:
159-162. [(30).iv.1952.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Cole, A.C.,Jr.'
      reference.citation_year.should == '1952a'
      reference.year.should == 1952
      reference.title.should == 'A new subspecies of Trachymyrmex smithi from New Mexico'
      reference.journal.should == 'Journal of the Tennessee Academy of Science'
      reference.series_volume_issue.should == '27'
      reference.pagination.should == '159-162'
      reference.date.should == '(30).iv.1952'
    end

    it "should handle a <span> in the title" do
      contents = make_contents %s{
Dumpert, K., Maschwitz, U. & Weissflog, A. 2006. Description of five new weaver ant species of<span style="mso-spacerun: yes"> </span><i style="mso-bidi-font-style: normal">Camponotus</i> subgenus <i style="mso-bidi-font-style:normal">Karavaievia</i> Emery, 1925 from Malaysia and Thailand, with contribution to their biology, especially to colony foundation. <i style="mso-bidi-font-style:normal">Myrmecologische Nachrichten</i> <b style="mso-bidi-font-weight:normal">8</b>: 69-82. 
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.title.should == 'Description of five new weaver ant species of Camponotus subgenus Karavaievia Emery, 1925 from Malaysia and Thailand, with contribution to their biology, especially to colony foundation'
    end

    it "should handle a colon in the title" do
      contents = make_contents %s{
Douwes, P., Jessen, K. & Buschinger, A. 1988. <i style="mso-bidi-font-style:normal">Epimyrma adlerzi</i> sp. n. from Greece: morphology and life history. <i style="mso-bidi-font-style:normal">Entomologica Scandinavica</i> <b style="mso-bidi-font-weight:normal">19</b>: 239-249. [28.ix.1988.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.title.should == 'Epimyrma adlerzi sp. n. from Greece: morphology and life history' 
    end

    it "should handle a series indicator" do
      contents = make_contents %s{
Dupuis, C. 1986. Dates de publication de l'Histoire Naturelle Générale et Particulière des Crustacés et des Insectes (1802-1805) par Latreille dans le "Buffon de Sonnini." <i style="mso-bidi-font-style:normal">Annales de la Société Entomologique de France</i> (N.S.) <b style="mso-bidi-font-weight:normal">22</b>: 205-210. [30.vi.1986.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.series_volume_issue.should == '(N.S.) 22' 
    end

    it "should handle when the bold volume immediately follows the italic title" do
      contents = make_contents %s{
DuBois, M.B. 1998a. The first fossil Dorylinae, with notes on fossil Ecitoninae. <i style="mso-bidi-font-style:normal">Entomological News </i><b style="mso-bidi-font-weight: normal">109</b>: 136-142. [1998.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.title.should == 'The first fossil Dorylinae, with notes on fossil Ecitoninae'
    end

    it "should handle a space after the hyphen in the pagination" do
      contents = make_contents %s{
DuBois, M.B. 1993. What's in a name? A clarification of <i style="mso-bidi-font-style: normal">Stenamma westwoodi, S. debile</i>, and <i style="mso-bidi-font-style: normal">S. lippulum. Sociobiology</i> <b style="mso-bidi-font-weight:normal">21</b>: 299- 334. [(31.xii).1993.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.pagination.should == '299- 334'
    end

  end

  it 'should skip over a note' do
    contents = make_contents %s{Note: in publications the following name appears as either Dubovikoff or Dubovikov; the latter is used here throughout.  }
    Bolton::ReferenceGrammar.should_not_receive(:parse)
    @bibliography.import_html contents
  end

  describe 'importing book references' do
    it "should import a book reference" do
      contents = make_contents "Dixon, F. 1940. <i style='mso-bidi-font-style:normal'>The geology
and fossils of the Tertiary and Cretaceous formation of Sussex</i>: 422 pp.
London. [(31).xii.1850.]"
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dixon, F.'
      reference.citation_year.should == '1940'
      reference.year.should == 1940
      reference.title.should == "The geology and fossils of the Tertiary and Cretaceous formation of Sussex"
      reference.pagination.should == '422 pp.'
      reference.place.should == 'London'
      reference.date.should == '(31).xii.1850'
      reference.reference_type.should == 'BookReference'
    end

    it "should add the book information to the title" do
      contents = make_contents %s{
Dumpert,
K. 1994. <i style='mso-bidi-font-style:normal'>Das Sozialleben der Ameisen</i>.
<b style='mso-bidi-font-weight:normal'>2</b>., neubearbeitete Auflage: 257 pp.
Berlin &amp; Hamburg. [(31.xii).1994.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dumpert, K.'
      reference.citation_year.should == '1994'
      reference.year.should == 1994
      reference.title.should == 'Das Sozialleben der Ameisen. 2., neubearbeitete Auflage'
      reference.place.should == 'Berlin & Hamburg'
      reference.pagination.should == '257 pp.'
      reference.date.should == '(31.xii).1994'
    end

    it "should handle a subtitle (without italics)" do
      contents = make_contents %s{
Drury, D. 1773. <i style="mso-bidi-font-style:normal">Illustrations of Natural History</i>. Wherein are exhibited upwards of two hundred and twenty figures of exotic insects. <b style="mso-bidi-font-weight:normal">2</b>: 90 pp. London. [(31.xii).1773.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.title.should == 'Illustrations of Natural History. Wherein are exhibited upwards of two hundred and twenty figures of exotic insects. 2' 
    end

    it "should handle an edition" do
      contents = make_contents %s{
Donisthorpe, H. 1927b. <i style="mso-bidi-font-style:normal">British Ants, their life-history and classification</i> (2nd. edition): 436 pp. London. [(31.xii).1927.]
      }
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.title.should == 'British Ants, their life-history and classification (2nd. edition)' 
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
