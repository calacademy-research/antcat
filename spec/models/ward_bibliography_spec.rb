require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardBibliography do
  before do
    @bibliography = WardBibliography.new
  end

  describe "importing - full stack" do
    it "should import a book reference and an article reference" do
      contents = <<-CONTENTS
        <html>
          <body>
            <table>
              <tr>
              </tr>
              <tr height=12>
                <td></td>
                <td height=12 class=xl65 align=right>5523</td>
                <td class=xl65>Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.</td>
                <td class=xl65>1978d.</td>
                <td class=xl65>197804</td>
                <td class=xl65>Records of insect collection.</td>
                <td class=xl65>Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.</td>
                <td class=xl65>{Formicidae pp. 4-6.}At least, I think so</td>
                <td class=xl65>PSW</td>
              </tr>
              <tr height=12>
                <td></td>
                <td height=12 class=xl65 align=right>4523</td>
                <td class=xl65>Dawah, H. A.;Ward, P.S.</td>
                <td class=xl65>1975d.</td>
                <td class=xl65>197501</td>
                <td class=xl65>Ants.</td>
                <td class=xl65>New York: Wiley, 322 pp.</td>
                <td class=xl65>Notes</td>
                <td class=xl65>MW</td>
              </tr>
            </table>
          </body>
        </html>
      CONTENTS

      @bibliography.import_html(contents, false)

      Author.count.should == 4
      Author.all.map(&:name).sort.should == ["Abdul-Rassoul, M. S.", "Dawah, H. A.", "Othman, N. Y.", "Ward, P.S."]

      Publisher.count.should == 1
      publisher = Publisher.first
      publisher.name.should == 'Wiley'
      publisher.place.should == 'New York'

      Journal.count.should == 1
      Journal.first.title.should == "Bull. Nat. Hist. Res. Cent. Univ. Baghdad"

      ArticleReference.count.should == 1
      article = ArticleReference.first
      article.authors.map(&:name).sort.should == ["Abdul-Rassoul, M. S.", "Dawah, H. A.", "Othman, N. Y."]
      article.citation_year.should == "1978d"
      article.cite_code.should == "5523"
      article.date.should == "197804"
      article.editor_notes.should == "At least, I think so"
      article.possess.should == 'PSW'
      article.public_notes.should == "Formicidae pp. 4-6."
      article.taxonomic_notes.should be_nil
      article.title.should == "Records of insect collection"
      #article.year.should == 1978

      BookReference.count.should == 1
      book = BookReference.first
      book.authors.map(&:name).sort.should == ["Dawah, H. A.", "Ward, P.S."]
      book.citation_year.should == "1975d"
      book.cite_code.should == "4523"
      book.date.should == "197501"
      book.editor_notes.should == "Notes"
      book.possess.should == 'MW'
      book.public_notes.should be_nil
      book.taxonomic_notes.should be_nil
      book.title.should == "Ants"
      book.year.should == 1975
    end
  end

  describe "importing, stubbing actual model creation" do
    before do
      Reference.stub!(:import)
    end

    describe "importing from a file" do
      it "should pass the file contents to the import method" do
        File.stub!(:read).and_return('contents')
        @bibliography.should_receive(:import_html).with('contents', false, false)
        @bibliography.import_file('filename')
      end

      it "should detect a post-95 format file" do
        File.stub!(:read).and_return('contents')
        @bibliography.should_receive(:import_html).with('contents', true, false)
        @bibliography.import_file('filename96')
      end
    end

    describe "importing html" do
      it "should import a record from the second row of the first table it finds" do
        contents = <<-CONTENTS
        <html>
          <body>
            <table>
              <tr>
              </tr>
              <tr height=12>
                <td></td>
                <td height=12 class=xl65 align=right>5523</td>
                <td class=xl65>Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.</td>
                <td class=xl65>1978d.</td>
                <td class=xl65>197804</td>
                <td class=xl65>Records of insect collection.</td>
                <td class=xl65>Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.</td>
                <td class=xl65>{Formicidae pp. 4-6.}At least, I think so</td>
                <td class=xl65>PSW</td>
              </tr>
            </table>
          </body>
        </html>
        CONTENTS
        @bibliography.should_receive(:parse).with(
          :authors => "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.",
          :year => "1978d",
          :date => '197804',
          :title => 'Records of insect collection',
          :citation => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6",
          :public_notes => 'Formicidae pp. 4-6.',
          :editor_notes => 'At least, I think so',
          :taxonomic_notes => nil,
          :cite_code => '5523',
          :possess => 'PSW')
          @bibliography.import_html(contents, false)
      end

      it "should read from the second row of the first table it finds and continue until first blank row" do
        contents = "
        <html><body><table><tr></tr>
          <tr>
            <td></td>
            <td>1</td>
            <td></td><td></td><td></td><td></td><td></td><td></td><td></td>
          </tr>
          <tr>
            <td></td>
            <td>2</td>
            <td></td><td></td><td></td><td></td><td></td><td></td><td></td>
          </tr>
          <tr>
            <td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
          </tr>
          <tr>
            <td></td>
            <td>3</td>
            <td></td><td></td><td></td><td></td><td></td><td></td><td></td>
          </tr>
        </table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:cite_code => '1'))
        @bibliography.should_receive(:parse).with(hash_including(:cite_code => '2'))
        @bibliography.import_html(contents, false)
      end

      it "should collapse lines" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Records of insect collection (Part I) in the Natural History
          Research Centre, Baghdad.</td>
        <td></td><td></td><td></td></tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:title => 'Records of insect collection (Part I) in the Natural History Research Centre, Baghdad'))
        @bibliography.import_html(contents, false)
      end

      describe "importing notes" do
        it "reads public notes" do
          contents = "<html><body><table><tr></tr><tr>
                <td></td>
                <td>123</td>
                <td></td>
                <td></td>
                <td></td>
                <td>title</td>
                <td>journal</td>
                <td>{Notes}</td>
                <td></td>
                <td></td>
            </tr></table></body></html>"

            @bibliography.should_receive(:parse).with(hash_including(:public_notes => 'Notes', :editor_notes => ''))
            @bibliography.import_html contents, false
        end
        it "reads editor's notes" do
          contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
              <td>title</td><td>journal</td>
              <td>Notes</td>
              <td></td><td></td></tr></table></body></html>"
              @bibliography.should_receive(:parse).with(hash_including(:public_notes => nil, :editor_notes => 'Notes'))
              @bibliography.import_html contents, false
        end
        it "reads public and editor's notes" do
          contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
              <td>title</td><td>journal</td>
              <td>{Public} Editor</td>
              <td></td><td></td></tr></table></body></html>"
              @bibliography.should_receive(:parse).with(hash_including(:public_notes => 'Public', :editor_notes => 'Editor'))
              @bibliography.import_html contents, false
        end
        it "handles linebreaks and italics" do
          contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
              <td>title</td><td>journal</td>
              <td>
    {Page 53: <font class=font7>Myrmicium</font><font class=font0>.}
    And </font><font class=font7>Myrmecium</font><font class=font0>
    (misspelling).</font>
              </td>
              <td></td><td></td></tr></table></body></html>"
              @bibliography.should_receive(:parse).with(hash_including(:public_notes => 'Page 53: *Myrmicium*.',
                                                                       :editor_notes => 'And *Myrmecium* (misspelling).'))
              @bibliography.import_html contents, false
        end

      end

      it "should convert vertical bars (Phil's indication of italics) to asterisks (Markdown)" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
              <td>Records of |Formicidae|.</td>
            <td></td><td></td><td></td></tr></table></body></html>"
            @bibliography.should_receive(:parse).with(hash_including(:title => 'Records of *Formicidae*'))
            @bibliography.import_html contents, false
      end

      it "should convert Microsoft's indication of italics to asterisks" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Interaction between the ants <font class=font7>Zacryptocerus
  maculatus</font><font class=font0> and </font><font class=font7>Azteca
  trigona</font><font class=font0>.</font></td>
        <td></td><td></td><td></td></tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:title => 'Interaction between the ants *Zacryptocerus maculatus* and *Azteca trigona*'))
        @bibliography.import_html contents, false
      end

      it "should convert entities to characters" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Love &amp; Death</td>
        <td></td><td></td><td></td></tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:title => 'Love & Death'))
        @bibliography.import_html contents, false
      end

      it "should remove period from end of year" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td>
          <td>1978.</td><td></td><td></td>
        <td></td><td></td><td></td></tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:year => '1978'))
        @bibliography.import_html contents, false
      end

      it "should remove period from end of title" do
        contents = "<html><body><table><tr></tr><tr>
            <td></td>
            <td>123</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Title with period.</td>
            <td>journal</td>
            <td>{Notes}</td>
            <td></td>
            <td></td>
        </tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:title => 'Title with period'))
        @bibliography.import_html contents, false
      end

      it "should remove period from end of citation" do
        contents = "<html><body><table><tr></tr><tr>
            <td></td>
            <td>123</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Title</td>
            <td>Citation with period.</td>
            <td>{Notes}</td>
            <td></td>
            <td></td>
        </tr></table></body></html>"
        @bibliography.should_receive(:parse).with(hash_including(:citation => 'Citation with period'))
        @bibliography.import_html contents, false
      end

    end

    describe "parsing columns" do
      it "should parse out the authors and citation information" do
        @bibliography.parse(
          :authors => "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.",
          :year => "1978d",
          :date => '197804',
          :title => 'Records of insect collection',
          :citation => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6",
          :public_notes => 'Formicidae pp. 4-6.',
          :editor_notes => 'At least, I think so',
          :taxonomic_notes => nil,
          :cite_code => '5523',
          :possess => 'PSW'
        ).should == {
          :authors => ["Abdul-Rassoul, M. S.", "Dawah, H. A.", "Othman, N. Y."],
          :citation_year => "1978d",
          :year => 1978,
          :date => '197804',
          :title => 'Records of insect collection',
          :article => {:journal => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad", :series_volume_issue => "7(2)", :pagination => "1-6"},
          :public_notes => 'Formicidae pp. 4-6.',
          :editor_notes => 'At least, I think so',
          :taxonomic_notes => nil,
          :cite_code => '5523',
          :possess => 'PSW'}
      end
    end

    describe "importing post-1995 data" do
      it "should import a record" do
        contents = <<-CONTENTS
        <html>
          <body>
            <table>
              <tr>
              </tr>
              <tr height=12>
                <td></td>
                <td height=12 class=xl65 align=right>96-1828</td>
                <td class=xl65>Schlick-Steiner, B. C.; Steiner, F. M.; Seifert, B.; Stauffer, C.; Christian, E.; Crozier, R. H.</td>
                <td class=xl65>1978.</td>
                <td class=xl65>197804</td>
                <td class=xl65>Records of insect collection.</td>
                <td class=xl65>Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.</td>
                <td>Austromorium</td>
                <td class=xl65>Published online: 2005102</td>
                <td class=xl65>PSW</td>
              </tr>
            </table>
          </body>
        </html>
        CONTENTS
        @bibliography.should_receive(:parse).with(
          :authors => "Schlick-Steiner, B. C.; Steiner, F. M.; Seifert, B.; Stauffer, C.; Christian, E.; Crozier, R. H.",
          :year => "1978",
          :date => '197804',
          :title => 'Records of insect collection',
          :citation => 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6',
          :public_notes => nil,
          :editor_notes => 'Published online: 2005102',
          :taxonomic_notes => 'Austromorium',
          :cite_code => '96-1828',
          :possess => 'PSW')
          @bibliography.import_html contents, true
      end
    end

    describe "parsing" do

      describe "parsing authors" do
        it "should parse a single author into a one-element array" do
          @bibliography.parse_authors('Fisher, B.L.').should == ['Fisher, B.L.']
        end
        it "should parse multiple authors" do
          @bibliography.parse_authors('Fisher, B.L.; Wheeler, W.M.').should == ['Fisher, B.L.', 'Wheeler, W.M.']
        end
      end

      describe "parsing the citation" do
        describe "parsing a journal citation" do
          it "should extract article, issue and journal information" do
            @bibliography.parse_citation('Behav. Ecol. Sociobiol. 4:163-181.').should == 
              {:article => {:journal => 'Behav. Ecol. Sociobiol.', :series_volume_issue => '4', :pagination => '163-181'}}
          end

          it "should parse a citation with just a single page issue" do
            @bibliography.parse_citation("Entomol. Mon. Mag. 92:8.").should == 
              {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92', :pagination => '8'}}
          end

          it "should parse a citation with an issue issue" do
            @bibliography.parse_citation("Entomol. Mon. Mag. 92(32):8.").should == 
              {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92(32)', :pagination => '8'}}
          end

          it "should parse a citation with a series issue" do
            @bibliography.parse_citation('Ann. Mag. Nat. Hist. (10)8:129-131.').should == 
              {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(10)8', :pagination => '129-131'}}
          end

          it "should parse a citation with series, volume and issue" do
            @bibliography.parse_citation('Ann. Mag. Nat. Hist. (I)C(xix):129-131.').should ==
              {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'}}
          end
        end

        describe "parsing a book citation" do
          it "should extract the place, pagination and publisher" do
            @bibliography.parse_citation('Melbourne: CSIRO Publications, vii + 70 pp.').should ==
              {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
          end

          it "should parse a book citation with complicate pagination" do
            @bibliography.parse_citation('Tokyo: Keishu-sha, 247 pp. + 14 pl. + 4 pp. (index).').should ==
              {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => '247 pp. + 14 pl. + 4 pp. (index).'}}
          end
        end

        describe "parsing a nested citation" do
          it "should handle parsing with no page numbers" do
            @bibliography.parse_citation(
              'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.').should ==
              {:other => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.'}
          end
          it "should handle parsing with page numbers" do
            @bibliography.parse_citation(
              'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.').should ==
              {:other => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.'}
          end
        end

        describe "parsing an unknown format" do
          it "should consider it an unknown format" do
            @bibliography.parse_citation('asdf').should == {:other => 'asdf'}
          end
        end
      end
    end
  end
end
