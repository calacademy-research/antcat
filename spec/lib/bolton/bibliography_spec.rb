require 'spec_helper'

describe Bolton::Bibliography do
  describe "importing from a file" do
    before do
      @bibliography = Bolton::Bibliography.new 'filename'
    end

    it "importing a file should call #import_html" do
      File.should_receive(:read).with('filename').and_return('contents')
      @bibliography.should_receive(:import_html).with('contents')
      @bibliography.import_file
      Bolton::Reference.all.should be_empty
    end

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
    end

    it "should import a book reference" do
      contents = make_contents "Dixon, F. 1940. <i style='mso-bidi-font-style:normal'>The geology
and fossils of the Tertiary and Cretaceous formation of Sussex</i>: 422 pp.
London. [(31).xii.1850.]"
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dixon, F.'
      reference.year.should == '1940'
      reference.title.should == "The geology and fossils of the Tertiary and Cretaceous formation of Sussex"
      reference.pagination.should == '422 pp.'
      reference.place.should == 'London'
      reference.date.should == '(31).xii.1850.'
    end

    it "should handle comma instead of period before date" do
      contents = make_contents "Clark, J. 1934b. New Australian ants. Memoirs of the National Museum, Victoria 8: 21-47, [(30).ix.1934.]"
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Clark, J.'
      reference.year.should == '1934b'
      reference.title_and_citation.should == 'New Australian ants. Memoirs of the National Museum, Victoria 8: 21-47'
      reference.date.should == '(30).ix.1934.'
    end

    it "should handle missing date" do
      contents = make_contents "Dumpert, K. 2006. Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006. Myrmecologische Nachrichten 9: 89."
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Dumpert, K.'
      reference.year.should == '2006'
      reference.title_and_citation.should == "Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006. Myrmecologische Nachrichten 9: 89"
      reference.date.should be_nil
    end
    
    it "should handle missing space after date" do
      contents = make_contents "Arnold, G. 1960a.Aculeate Hymenoptera from the Drakensberg Mountains, Natal. Annals of the Natal Museum 15: 79-87."
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Arnold, G.'
      reference.year.should == '1960a'
      reference.title_and_citation.should == "Aculeate Hymenoptera from the Drakensberg Mountains, Natal. Annals of the Natal Museum 15: 79-87"
      reference.date.should be_nil
    end

    it "should handle missing space after author" do
      contents = make_contents 'Brown, W.L.,Jr.1948a. A new Stictoponera, with notes on the genus. Psyche 54 (1947): 263-264.'
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Brown, W.L.,Jr.'
      reference.year.should == '1948a'
      reference.title_and_citation.should == 'A new Stictoponera, with notes on the genus. Psyche 54 (1947): 263-264'
      reference.date.should be_nil
    end

    it "should handle missing period after year" do
      contents = make_contents 'Cole, A.C.,Jr. 1952a A new subspecies of Trachymyrmex smithi from New Mexico. Journal of the Tennessee Academy of Science 27: 159-162.'
      @bibliography.import_html contents
      reference = Bolton::Reference.first
      reference.authors.should == 'Cole, A.C.,Jr.'
      reference.year.should == '1952a'
      reference.title_and_citation.should == 'A new subspecies of Trachymyrmex smithi from New Mexico. Journal of the Tennessee Academy of Science 27: 159-162'
      reference.date.should be_nil
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
