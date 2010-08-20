require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoltonReference do
  describe "importing from a file" do
    before do
      @filename = 'foo.txt'
    end

    it "should do nothing if file is empty" do
      File.should_receive(:read).with(@filename).and_return('')
      BoltonReference.import(@filename)
      BoltonReference.all.should be_empty
    end

    it "should import a record from the first reference it finds" do
      file_contents = make_contents "Abe,
M. &amp; Smith, D.R. 1991d. The genus-group names of Symphyta and their type
species. <i style='mso-bidi-font-style:normal'>Esakia</i> <b style='mso-bidi-font-weight:
normal'>31</b>: 1-115. [31.vii.1991.]"
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Abe, M. & Smith, D.R.'
      reference.year.should == '1991d'
      reference.title_and_citation.should == 'The genus-group names of Symphyta and their type species. Esakia 31: 1-115'
      reference.date.should == '31.vii.1991.'
    end

    it "should handle comma instead of period before date" do
      file_contents = make_contents "Clark, J. 1934b. New Australian ants. Memoirs of the National Museum, Victoria 8: 21-47, [(30).ix.1934.]"
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Clark, J.'
      reference.year.should == '1934b'
      reference.title_and_citation.should == 'New Australian ants. Memoirs of the National Museum, Victoria 8: 21-47'
      reference.date.should == '(30).ix.1934.'
    end

    it "should handle missing date" do
      file_contents = make_contents "Dumpert, K. 2006. Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006. Myrmecologische Nachrichten 9: 89."
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Dumpert, K.'
      reference.year.should == '2006'
      reference.title_and_citation.should == "Camponotus (Karavaievia) khaosokensis nom. n. proposed as replacement name for Camponotus (Karavaievia) hoelldobleri Dumpert, 2006. Myrmecologische Nachrichten 9: 89"
      reference.date.should be_nil
    end
    
    it "should handle missing space after date" do
      file_contents = make_contents "Arnold, G. 1960a.Aculeate Hymenoptera from the Drakensberg Mountains, Natal. Annals of the Natal Museum 15: 79-87."
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Arnold, G.'
      reference.year.should == '1960a'
      reference.title_and_citation.should == "Aculeate Hymenoptera from the Drakensberg Mountains, Natal. Annals of the Natal Museum 15: 79-87"
      reference.date.should be_nil
    end

    it "should handle missing space after author" do
      file_contents = make_contents 'Brown, W.L.,Jr.1948a. A new Stictoponera, with notes on the genus. Psyche 54 (1947): 263-264.'
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Brown, W.L.,Jr.'
      reference.year.should == '1948a'
      reference.title_and_citation.should == 'A new Stictoponera, with notes on the genus. Psyche 54 (1947): 263-264'
      reference.date.should be_nil
    end

    it "should handle missing period after year" do
      file_contents = make_contents 'Cole, A.C.,Jr. 1952a A new subspecies of Trachymyrmex smithi from New Mexico. Journal of the Tennessee Academy of Science 27: 159-162.'
      File.should_receive(:read).with(@filename).and_return(file_contents)
      BoltonReference.import(@filename)
      reference = BoltonReference.first
      reference.authors.should == 'Cole, A.C.,Jr.'
      reference.year.should == '1952a'
      reference.title_and_citation.should == 'A new subspecies of Trachymyrmex smithi from New Mexico. Journal of the Tennessee Academy of Science 27: 159-162'
      reference.date.should be_nil
    end
  end

  describe "matching Bolton's references against Ward's" do
    it "should find an exact match" do
      reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    :title => "Ants of the genus Formica L. of Mongolia and northeast Tibet",
                                    :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      bolton.match.should == reference
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
