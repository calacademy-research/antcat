require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do
  it "should be able create a new instance" do
    Reference.create!
  end

  describe "importing" do
    describe "importing from a file" do
      before do
        @filename = 'foo.htm'
      end

      it "should do nothing if file is empty" do
        File.should_receive(:read).with(@filename).and_return('')
        Reference.import(@filename)
        Reference.all.should be_empty
      end

      it "should import a record from the second row of the first table it finds" do
        @file_contents = "
          <html>
            <body>
              <table>
                <tr>
                </tr>
                <tr height=12>
                  <td height=12 class=xl65 align=right>5523</td>
                  <td class=xl65>Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.</td>
                  <td class=xl65>1978.</td>
                  <td class=xl65>197804</td>
                  <td class=xl65>Records of insect collection.</td>
                  <td class=xl65>Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.</td>
                  <td class=xl65>{Formicidae pp. 4-6.}</td>
                  <td class=xl65>PSW</td>
                </tr>
              </table>
            </body>
          </html>
        "
        File.should_receive(:read).with(@filename).and_return(@file_contents)
        Reference.import(@filename)
        reference = Reference.first
        reference.authors.should == "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y."
        reference.year.should == "1978."
        reference.date.should == '197804'
        reference.title.should == 'Records of insect collection.'
        reference.citation.should == 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.'
        reference.notes.should == '{Formicidae pp. 4-6.}'
        reference.cite_code.should == '5523'
        reference.possess.should == 'PSW'
        reference.excel_file_name.should == @filename
      end

      it "should collapse lines" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td><td></td><td></td><td></td>
            <td>Records of insect collection (Part I) in the Natural History
            Research Centre, Baghdad.</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Reference.import(@filename)
        Reference.first.title.should == 'Records of insect collection (Part I) in the Natural History Research Centre, Baghdad.'
      end

      it "should convert vertical bars (Phil's indication of italics) to asterisks (Markdown)" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td><td></td><td></td><td></td>
            <td>Records of |Formicidae|.</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Reference.import(@filename)
        Reference.first.title.should == 'Records of *Formicidae*.'
      end

      it "should convert Microsoft's indication of italics to asterisks" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td><td></td><td></td><td></td>
            <td>Interaction between the ants <font class=font7>Zacryptocerus
  maculatus</font><font class=font0> and </font><font class=font7>Azteca
  trigona</font><font class=font0>.</font></td>
          <td></td><td></td><td></td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Reference.import(@filename)
        Reference.first.title.should == 'Interaction between the ants *Zacryptocerus maculatus* and *Azteca trigona*.'
      end

      it "should convert entities to characters" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td><td></td><td></td><td></td>
            <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Reference.import(@filename)
        Reference.first.title.should == 'Love & Death'
      end
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      Factory(:reference, :authors => 'Bolton')
      Reference.search(:author => 'foo').should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = Factory(:reference, :authors => 'Bolton')
      Factory(:reference, :authors => 'Fisher')
      Reference.search(:author => 'Bolton').should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author" do
      Factory(:reference, :authors => 'Bolton', :year => '2010')
      Factory(:reference, :authors => 'Bolton', :year => '1995')
      Factory(:reference, :authors => 'Fisher', :year => '2011')
      Factory(:reference, :authors => 'Fisher', :year => '1996')
      Reference.search(:start_year => '2012', :end_year => '2013', :author => 'Fisher').should be_empty
    end


    it "should return the one reference for a given year and author" do
      Factory(:reference, :authors => 'Bolton', :year => '2010')
      Factory(:reference, :authors => 'Bolton', :year => '1995')
      Factory(:reference, :authors => 'Fisher', :year => '2011')
      reference = Factory(:reference, :authors => 'Fisher', :year => '1996')
      Reference.search(:start_year => '1996', :end_year => '1996', :author => 'Fisher').should == [reference]
    end

    describe "searching by year" do
      before do
        Factory(:reference, :year => '1994')
        Factory(:reference, :year => '1995')
        Factory(:reference, :year => '1996')
        Factory(:reference, :year => '1997')
        Factory(:reference, :year => '1998')
      end

      it "should return an empty array if nothing is found for year" do
        Reference.search(:start_year => '1992', :end_year => '1993').should be_empty
      end

      it "should find entries less than or equal to the end year" do
        Reference.search(:end_year => '1995').map(&:year).should =~ ['1994', '1995']
      end

      it "should find entries greater than or equal to the start year" do
        Reference.search(:start_year => '1998').map(&:year).should =~ ['1998']
      end

      it "should find entries in between the start year and the end year (inclusive)" do
        Reference.search(:start_year => '1995', :end_year => '1996').map(&:year).should =~ ['1995', '1996']
      end

      it "should find references in the year of the end range, even if they have extra characters" do
        Factory(:reference, :year => '2004.')
        Reference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ ['2004.']
      end

    end

  end
end
