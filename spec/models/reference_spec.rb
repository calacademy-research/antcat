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
end
