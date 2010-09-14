require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardReference do
  it "belongs to a reference" do
    ward_reference = WardReference.create!
    ward_reference.reference.should be_nil
    reference = Factory :reference
    ward_reference.update_attribute :reference, reference
    ward_reference.reference.should == reference
  end

  describe "export" do
    describe "exporting all references" do
      it "should convert each to the right format, then send them to Reference" do
        ward_references = ['1', '2'].inject([]) do |ward_references, value|
          ward_reference = mock_model WardReference
          ward_reference.should_receive(:export)
          ward_references << ward_reference
        end
        WardReference.should_receive(:all).and_return ward_references

        WardReference.export
      end
    end

    describe "exporting a reference" do
      it "should convert each to the right format, then send them to Reference" do
        reference = Factory(:reference)
        ward_reference = WardReference.new :authors => 'Fisher', :citation => 'Ants 1:1'
        Reference.should_receive(:import).with(hash_including(:article => {:journal => 'Ants', :pagination => '1',
                                                              :series_volume_issue => '1'})).and_return reference
        ward_reference.export
        ward_reference.reference.should == reference
      end
    end

    describe "creating import format" do
      describe "notes" do
        it 'should parse out public notes' do
          WardReference.new(:notes => "{Notes}").to_import_format.should include(:public_notes => 'Notes', :editor_notes => '')
        end
        it "should parse out editor notes" do
          WardReference.new(:notes => 'Notes').to_import_format.should include(:public_notes => '', :editor_notes => 'Notes')
        end
        it "should parse out public and editor's notes" do
          WardReference.new(:notes => '{Public} Editor').to_import_format.should include(:public_notes => 'Public', :editor_notes => 'Editor')
        end
      end

      it "should remove period from end of year" do
        WardReference.new(:year => '1978d.').to_import_format.should include(:citation_year => '1978d')
      end

      it "should remove period from end of title" do
        WardReference.new(:title => 'Title with period.').to_import_format.should include(:title => 'Title with period')
      end

      describe "parsing authors" do
        it "should parse a single author into a one-element array" do
          WardReference.new(:authors => 'Fisher, B.L.').to_import_format.should include(:authors => ['Fisher, B.L.'])
        end
        it "should parse multiple authors" do
          WardReference.new(:authors => 'Fisher, B.L.; Wheeler, W.M.').to_import_format.should include(:authors => ['Fisher, B.L.', 'Wheeler, W.M.'])
        end
      end

      describe "parsing the citation" do
        describe "parsing a journal citation" do
          it "should extract article, issue and journal information" do
            WardReference.new(:citation => 'Behav. Ecol. Sociobiol. 4:163-181.').to_import_format.should include(
              :article => {:journal => 'Behav. Ecol. Sociobiol.', :series_volume_issue => '4', :pagination => '163-181'})
          end

          it "should parse a citation with just a single page issue" do
            WardReference.new(:citation => "Entomol. Mon. Mag. 92:8.").to_import_format.should include(
              :article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92', :pagination => '8'})
          end

          it "should parse a citation with an issue issue" do
            WardReference.new(:citation => "Entomol. Mon. Mag. 92(32):8.").to_import_format.should include(
              :article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92(32)', :pagination => '8'})
          end

          it "should parse a citation with a series issue" do
            WardReference.new(:citation => 'Ann. Mag. Nat. Hist. (10)8:129-131.').to_import_format.should include(
              :article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(10)8', :pagination => '129-131'})
          end

          it "should parse a citation with series, volume and issue" do
            WardReference.new(:citation => 'Ann. Mag. Nat. Hist. (I)C(xix):129-131.').to_import_format.should include(
              :article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'})
          end
        end

        describe "parsing a book citation" do
          it "should extract the place, pagination and publisher" do
            WardReference.new(:citation => 'Melbourne: CSIRO Publications, vii + 70 pp.').to_import_format.should include(
              :book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'})
          end

          it "should parse a book citation with complicate pagination" do
            WardReference.new(:citation => 'Tokyo: Keishu-sha, 247 pp. + 14 pl. + 4 pp. (index).').to_import_format.should include(
              :book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => '247 pp. + 14 pl. + 4 pp. (index).'})
          end
        end

        describe "parsing a nested citation" do
          it "should handle parsing with no page numbers" do
            WardReference.new(:citation =>
              'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.').
              to_import_format.should include(
              :other => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.')
          end
          it "should handle parsing with page numbers" do
            WardReference.new(:citation =>
              'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.').
              to_import_format.should include(
              :other => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.')
          end
        end

        describe "parsing an unknown format" do
          it "should consider it an unknown format" do
            WardReference.new(:citation => 'asdf').to_import_format.should include(:other => 'asdf')
          end
        end
      end

      it "should convert to import format" do
        WardReference.new({
          :authors => "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.",
          :citation => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6",
          :cite_code => '5523',
          :date => '197804',
          :notes => '{Formicidae pp. 4-6.}At least, I think so',
          :possess => 'PSW',
          :taxonomic_notes => 'Tapinoma',
          :title => 'Records of insect collection',
          :year => "1978d",
        }).to_import_format.should == {
          :article => {:journal => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad", :series_volume_issue => "7(2)", :pagination => "1-6"},
          :authors => ["Abdul-Rassoul, M. S.", "Dawah, H. A.", "Othman, N. Y."],
          :citation_year => "1978d",
          :cite_code => '5523',
          :date => '197804',
          :editor_notes => 'At least, I think so',
          :possess => 'PSW',
          :public_notes => 'Formicidae pp. 4-6.',
          :taxonomic_notes => 'Tapinoma',
          :title => 'Records of insect collection',
        }
      end
    end
  end

end
