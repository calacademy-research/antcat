require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardReference do
  it "belongs to a reference" do
    ward_reference = WardReference.create!
    ward_reference.reference.should be_nil
    reference = Factory :reference
    ward_reference.update_attribute :reference, reference
    ward_reference.reference.should == reference
  end

  it "should not truncate long fields" do
    WardReference.create!(:authors => 'a' * 1000, :citation => 'c' * 2000, :notes => 'n' * 1500, :taxonomic_notes => 't' * 1700, :title => 'i' * 1876)
    reference = WardReference.first
    reference.authors.length.should == 1000
    reference.citation.length.should == 2000
    reference.notes.length.should == 1500
    reference.taxonomic_notes.length.should == 1700
    reference.title.length.should == 1876
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
        ward_reference.export.should == reference
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

      it "send itself along" do
        ward_reference = WardReference.create!(:title => 'Title with period.')
        ward_reference.to_import_format.should include(:id => ward_reference.id, :class => 'WardReference')
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
          it "should call the parser with the right arguments" do
            parser = mock
            ReferenceParser.stub!(:new).and_return parser
            citation = 'Melbourne: CSIRO Publications, vii + 70 pp.'
            parser.should_receive(:parse_book_citation).with(citation).and_return(:foo)
            WardReference.new(:citation => citation).to_import_format.should include(:book => :foo)
          end
        end

        describe "parsing a nested citation" do
          it "should handle parsing with no page numbers" do
            WardReference.new(:citation =>
              'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.').
              to_import_format.should include(
              :other => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310')
          end
          it "should handle parsing with page numbers" do
            WardReference.new(:citation =>
              'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.').
              to_import_format.should include(
              :other => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp')
          end
        end

        describe "parsing an unknown format" do
          it "should consider it an 'other' reference" do
            WardReference.new(:citation => 'asdf').to_import_format.should include(:other => 'asdf')
          end
        end
      end

      it "should convert to import format" do
        ward_reference = WardReference.create!({
          :authors => "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.",
          :citation => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6",
          :cite_code => '5523',
          :date => '197804',
          :notes => '{Formicidae pp. 4-6.}At least, I think so',
          :possess => 'PSW',
          :taxonomic_notes => 'Tapinoma',
          :title => 'Records of insect collection',
          :year => "1978d",
        })
        ward_reference.to_import_format.should == {
          :article => {:journal => "Bull. Nat. Hist. Res. Cent. Univ. Baghdad", :series_volume_issue => "7(2)", :pagination => "1-6"},
          :authors => ["Abdul-Rassoul, M. S.", "Dawah, H. A.", "Othman, N. Y."],
          :citation_year => "1978d",
          :cite_code => '5523',
          :class => ward_reference.class.to_s,
          :date => '197804',
          :editor_notes => 'At least, I think so',
          :id => ward_reference.id,
          :possess => 'PSW',
          :public_notes => 'Formicidae pp. 4-6.',
          :taxonomic_notes => 'Tapinoma',
          :title => 'Records of insect collection',
        }
      end
    end
  end

end
