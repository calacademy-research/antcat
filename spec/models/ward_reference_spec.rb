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

      it "not modify WardReference fields" do
        ward_reference = WardReference.create!(:authors => 'Bolton, B.')
        ward_reference.authors.should == 'Bolton, B.'
        ward_reference.to_import_format
        ward_reference.authors.should == 'Bolton, B.'
      end

      describe "converting to import format" do
        it "should convert an article reference" do
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

        it "should convert a book reference" do
          ward_reference = WardReference.create!({
            :authors => "Hölldobler, B.; Wilson, E. O.",
            :citation => "Cambridge, Mass.: Harvard University Press, xii + 732 pp.",
            :cite_code => '2841',
            :date => '19900328',
            :notes => '{Date from publisher.} Michael Fisher (Harvard Univ. Press), pers. comm., 2.x.1995',
            :possess => 'PSW',
            :title => 'The ants.',
            :year => "1990.",
          })
          ward_reference.to_import_format.should == {
            :book => {:publisher => {:name => 'Harvard University Press', :place => 'Cambridge, Mass.'}, :pagination => 'xii + 732 pp.'},
            :authors => ["Hölldobler, B.", "Wilson, E. O."],
            :citation_year => "1990",
            :cite_code => '2841',
            :class => ward_reference.class.to_s,
            :date => '19900328',
            :editor_notes => 'Michael Fisher (Harvard Univ. Press), pers. comm., 2.x.1995',
            :id => ward_reference.id,
            :possess => 'PSW',
            :public_notes => 'Date from publisher.',
            :taxonomic_notes => nil,
            :title => 'The ants',
          }
        end
      end
    end
  end

end
