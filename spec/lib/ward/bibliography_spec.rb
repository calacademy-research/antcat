require 'spec_helper'

describe Ward::Bibliography do
  describe "importing from a file" do
    it "should pass the file contents to the import method" do
      filename = Rails.root + 'data/file.htm'
      bibliography = Ward::Bibliography.new filename

      File.should_receive(:read).with(filename.to_s).and_return('contents')
      bibliography.should_receive(:import_html).with 'contents'

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
        :editor_notes => nil,
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
        :editor_notes => nil,
        :taxonomic_notes => nil,
        :title => 'Ants.',
        :year => '1975d.').and_return true
      Ward::Bibliography.new(Rails.root + '/ANTBIB_v1V.htm').import_html contents
    end

    describe "specific importing scenarios" do
      before do
        @bibliography = Ward::Bibliography.new 'file'
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

      describe "converting font tags designating italics to asterisks" do
        ['7', '8'].each do |font_number|
          it "should convert Microsoft's indication of italics (<font#{font_number}>) to asterisks" do
            contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
              <td>Interaction between the ants <font class=font#{font_number}>Zacryptocerus
              maculatus</font><font class=font0> and </font><font class=font7>Azteca
              trigona</font><font class=font0>.</font></td>
                  <td></td><td></td><td></td></tr></table></body></html>"
            WardReference.should_receive(:create!).with hash_including(:title => 'Interaction between the ants *Zacryptocerus maculatus* and *Azteca trigona*.')
            @bibliography.import_html contents
          end
        end

        it "should handle it when the td is italicized, and the font changes to normal" do
          contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
            <td class=xl68>Formicoxenus<font class=font0> ants</td>
                <td></td><td></td><td></td></tr></table></body></html>"
          WardReference.should_receive(:create!).with hash_including(:title => '*Formicoxenus* ants')
          @bibliography.import_html contents
        end

      end

      it "should convert entities to characters" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td><td></td><td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:title => 'Love & Death')
        @bibliography.import_html contents
      end

      it "should remove period from 'de' at end of author entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C. de; Abenante, Y. P. de.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C. de; Abenante, Y. P. de')
        @bibliography.import_html contents
      end

      it "should not remove period from single letter at end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C.')
        @bibliography.import_html contents
      end

      it "should not remove period from 'Jr.' at end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C., Jr.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C., Jr.')
        @bibliography.import_html contents
      end

      it "should not remove period from 'Sr.' at end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C., Sr.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C., Sr.')
        @bibliography.import_html contents
      end

      it "should not remove ) from '(ed.)' at end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C. (ed.)</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C. (ed.)')
        @bibliography.import_html contents
      end

      it "should not remove ) from '(eds.)' at end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C. (eds.)</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C. (eds.)')
        @bibliography.import_html contents
      end

      it "should remove 'and collaborators' from end of entry" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Zolessi, L. C. and collaborators</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Zolessi, L. C.')
        @bibliography.import_html contents
      end

      it "should fix Medeiros's name" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Medeiro, M. A. de</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Medeiros, M. A. de')
        @bibliography.import_html contents
      end

      it "should fix S.J. Gibron's name" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Gibron, J.; Sr.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Gibron, S. J.')
        @bibliography.import_html contents
      end

      it "should convert : to ;" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Gibron, J.: Ward, P. S.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Gibron, J.; Ward, P. S.')
        @bibliography.import_html contents
      end

      it "should remove links" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td><a>Gibron, J.</a></td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Gibron, J.')
        @bibliography.import_html contents
      end

      it "should handle mso-spacerun spans" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td><a>Gibron, J.</a></td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td class=xl65>Pp. 534-540 in: Hooker, J. D., Gunther, A. (eds.)<span style=\"mso-spacerun: yes\">  </span>An account of the petrological, botanical, and zoological collections made in Kerguelen's land and Rodriguez during the Transit of Venus expeditions, carried out by order of Her Majesty's Government in the years 1874-75.<span style=\"mso-spacerun: yes\">  </span>Philosophical Transactions of the Royal Society of London 168(extra volume):i-ix,1-579.</td>
          <td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:citation =>
          "Pp. 534-540 in: Hooker, J. D., Gunther, A. (eds.) An account of the petrological, botanical, and zoological collections made in Kerguelen's land and Rodriguez during the Transit of Venus expeditions, carried out by order of Her Majesty's Government in the years 1874-75. Philosophical Transactions of the Royal Society of London 168(extra volume):i-ix,1-579.")
        @bibliography.import_html contents
      end

      it "should handle a certain special case with part of the title in the citation" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td><a>Gibron, J.</a></td>
          <td></td><td></td>
          <td>Ants</td>
          <td class=xl65>Extrait des Mémoires publiés par la Société Portugaise des Sciences Naturelles. Lisbonne: Imprimerie de la Librairie Ferin, 4 pp.</td>
          <td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(
          :title => "Ants. Extrait des Mémoires publiés par la Société Portugaise des Sciences Naturelles",
          :citation => "Lisbonne: Imprimerie de la Librairie Ferin, 4 pp.")
        @bibliography.import_html contents
      end

      it "should handle another certain special case with part of the title in the citation" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td><a>Gibron, J.</a></td>
          <td></td><td></td>
          <td>Ants</td>
          <td class=xl65>Achtes Programm des Gymnasiums in Bozen. Bozen: Ebersche Buchdruckerei, 34 pp.</td>
          <td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(
          :title => "Ants. Achtes Programm des Gymnasiums in Bozen",
          :citation => "Bozen: Ebersche Buchdruckerei, 34 pp.")
        @bibliography.import_html contents
      end

      it "should fix weird space characters" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td> Cheng, C. H.; Fisher, B. L.</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Cheng, C. H.; Fisher, B. L.')
        @bibliography.import_html contents
      end

      it "should fix this dude without a period" do
        contents = "<html><body><table><tr></tr><tr><td></td><td>123</td>
          <td>Collingwood, C. A.; van Harten, A</td>
          <td></td><td></td>
          <td>Love &amp; Death</td>
          <td></td><td></td><td></td></tr></table></body></html>"
        WardReference.should_receive(:create!).with hash_including(:authors => 'Collingwood, C. A.; van Harten, A.')
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
              <td class=xl65>Published online: 2005102</td>
              <td class=xl65>Editor note</td>
              <td>Austromorium</td>
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
        :editor_notes => 'Editor note',
        :possess => 'PSW',
        :taxonomic_notes => 'Austromorium',
        :title => 'Records of insect collection.',
        :year => '1978.')
      Ward::Bibliography.new(Rails.root + '/ANTBIB96_v1V.htm').import_html contents
    end
  end
end
