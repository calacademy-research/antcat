require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardBibliography do
  before do
    @bibliography = WardBibliography.new
  end

  describe "importing from a file" do
    it "should pass the file contents to the import method" do
      File.stub!(:read).and_return('contents')
      @bibliography.should_receive(:import).with('contents', false, false)
      @bibliography.import_file('filename')
    end

    it "should detect a post-95 format file" do
      File.stub!(:read).and_return('contents')
      @bibliography.should_receive(:import).with('contents', true, false)
      @bibliography.import_file('filename96')
    end
  end

  describe "importing" do
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
                <td class=xl65>1978.</td>
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
      WardReference.should_receive(:create!).with(
        :authors => "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.",
        :year => "1978",
        :date => '197804',
        :title => 'Records of insect collection',
        :citation => 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6',
        :public_notes => 'Formicidae pp. 4-6.',
        :editor_notes => 'At least, I think so',
        :taxonomic_notes => nil,
        :cite_code => '5523',
        :possess => 'PSW')
      @bibliography.import(contents, false)
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
      WardReference.should_receive(:create!).with(hash_including(:cite_code => '1'))
      WardReference.should_receive(:create!).with(hash_including(:cite_code => '2'))
      @bibliography.import(contents, false)
    end

    it "should collapse lines" do
      contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Records of insect collection (Part I) in the Natural History
          Research Centre, Baghdad.</td>
        <td></td><td></td><td></td></tr></table></body></html>"
      WardReference.should_receive(:create!).with(hash_including(:title => 'Records of insect collection (Part I) in the Natural History Research Centre, Baghdad'))
      @bibliography.import(contents, false)
    end
  end

  describe "parsing notes" do
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

      WardReference.should_receive(:create!).with(hash_including(:public_notes => 'Notes', :editor_notes => ''))
      @bibliography.import contents, false
    end
    it "reads editor's notes" do
      contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
            <td>title</td><td>journal</td>
            <td>Notes</td>
            <td></td><td></td></tr></table></body></html>"
      WardReference.should_receive(:create!).with(hash_including(:public_notes => nil, :editor_notes => 'Notes'))
      @bibliography.import contents, false
    end
    it "reads public and editor's notes" do
      contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
            <td>title</td><td>journal</td>
            <td>{Public} Editor</td>
            <td></td><td></td></tr></table></body></html>"
      WardReference.should_receive(:create!).with(hash_including(:public_notes => 'Public', :editor_notes => 'Editor'))
      @bibliography.import contents, false
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
      WardReference.should_receive(:create!).with(hash_including(:public_notes => 'Page 53: *Myrmicium*.',
                                                                 :editor_notes => 'And *Myrmecium* (misspelling).'))
      @bibliography.import contents, false
    end

  end

  it "should convert vertical bars (Phil's indication of italics) to asterisks (Markdown)" do
    contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
            <td>Records of |Formicidae|.</td>
          <td></td><td></td><td></td></tr></table></body></html>"
    WardReference.should_receive(:create!).with(hash_including(:title => 'Records of *Formicidae*'))
    @bibliography.import contents, false
  end

  it "should convert Microsoft's indication of italics to asterisks" do
    contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
        <td>Interaction between the ants <font class=font7>Zacryptocerus
 maculatus</font><font class=font0> and </font><font class=font7>Azteca
 trigona</font><font class=font0>.</font></td>
      <td></td><td></td><td></td></tr></table></body></html>"
    WardReference.should_receive(:create!).with(hash_including(:title => 'Interaction between the ants *Zacryptocerus maculatus* and *Azteca trigona*'))
    @bibliography.import contents, false
  end

  it "should convert entities to characters" do
    contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
        <td>Love &amp; Death</td>
      <td></td><td></td><td></td></tr></table></body></html>"
    WardReference.should_receive(:create!).with(hash_including(:title => 'Love & Death'))
    @bibliography.import contents, false
  end

  it "should remove period from end of year" do
    contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td>
        <td>1978.</td><td></td><td></td>
      <td></td><td></td><td></td></tr></table></body></html>"
    WardReference.should_receive(:create!).with(hash_including(:year => '1978'))
    @bibliography.import contents, false
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
    WardReference.should_receive(:create!).with(hash_including(:title => 'Title with period'))
    @bibliography.import contents, false
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
    WardReference.should_receive(:create!).with(hash_including(:citation => 'Citation with period'))
    @bibliography.import contents, false
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
      WardReference.should_receive(:create!).with(
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
      @bibliography.import contents, true
    end
  end
end
