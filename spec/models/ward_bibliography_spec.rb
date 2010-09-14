require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardBibliography do
  describe "importing from a file" do
    it "should pass the file contents to the import method" do
      filename = Rails.root + 'data/file.htm'
      bibliography = WardBibliography.new filename

      File.should_receive(:read).with(filename.to_s).and_return('contents')
      bibliography.should_receive(:import_html).with('contents', false)

      bibliography.import_file
    end
  end

  describe "importing HTML" do
    it "should import contents of HTML into WardReferences" do
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
      WardReference.should_receive(:create!).with(
        :authors => 'Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.',
        :citation => 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.',
        :cite_code => '5523',
        :date => '197804',
        :filename => 'ANTBIB_v1V',
        :notes => '{Formicidae pp. 4-6.}At least, I think so',
        :possess => 'PSW',
        :taxonomic_notes => nil,
        :title => 'Records of insect collection.',
        :year => '1978d.').and_return true
      WardReference.should_receive(:create!).with(
        :authors => 'Dawah, H. A.;Ward, P.S.',
        :citation => 'New York: Wiley, 322 pp.',
        :cite_code => '4523',
        :date => '197501',
        :filename => 'ANTBIB_v1V',
        :notes => 'Notes',
        :possess => 'MW',
        :taxonomic_notes => nil,
        :title => 'Ants.',
        :year => '1975d.').and_return true
      WardBibliography.new(Rails.root + '/ANTBIB_v1V.htm').import_html contents
    end

    describe "specific importing scenarios" do
      before do
        @bibliography = WardBibliography.new 'file'
      end

      it "should read from the second row of the first table it finds and continue until first blank row" do
        contents = "
        <html><body><table>
          <tr>
          </tr>
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
        WardReference.should_receive(:create!).with(hash_including(:cite_code => '1')).and_return true
        WardReference.should_receive(:create!).with(hash_including(:cite_code => '2')).and_return true
      @bibliography.import_html contents
      end

      it "should collapse lines" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Records of insect collection (Part I) in the Natural History
          Research Centre, Baghdad.</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:title => 'Records of insect collection (Part I) in the Natural History Research Centre, Baghdad.')
        @bibliography.import_html contents
      end

      it "should convert vertical bars (Phil's indication of italics) to asterisks (Markdown)" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
            <td>Records of |Formicidae|.</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:title => 'Records of *Formicidae*.')
        @bibliography.import_html contents
      end

      it "should convert Microsoft's indication of italics to asterisks" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Interaction between the ants <font class=font7>Zacryptocerus
          maculatus</font><font class=font0> and </font><font class=font7>Azteca
          trigona</font><font class=font0>.</font></td>
              <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:title => 'Interaction between the ants *Zacryptocerus maculatus* and *Azteca trigona*.')
        @bibliography.import_html contents
      end

      it "should convert entities to characters" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:title => 'Love & Death')
        @bibliography.import_html contents
      end

    end
  end

  describe "importing post-1995 data" do
    it "should include taxonomic notes" do
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
        :citation => 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6.',
        :cite_code => '96-1828',
        :date => '197804',
        :filename => 'ANTBIB96_v1V',
        :notes => 'Published online: 2005102',
        :possess => 'PSW',
        :taxonomic_notes => 'Austromorium',
        :title => 'Records of insect collection.',
        :year => '1978.')
      WardBibliography.new(Rails.root + '/ANTBIB96_v1V.htm').import_html contents
    end
  end
end
