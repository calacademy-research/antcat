require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NestedCitationParser do

  describe "if it's not a nested reference" do
    describe "if it's empty" do
      it "should return nil" do
        [nil, ''].each do |citation|
          NestedCitationParser.parse(citation).should == nil
        end
      end
    end

    describe "if it's a book citation" do
      it "should return nil" do
        NestedCitationParser.parse('New York: Longmans, 36 pp.').should == nil
      end
    end
  end

  it "should work on a simple nesting" do
    parts = NestedCitationParser.parse('Pp. 32-45 in Mayer, D.M. Ants. Psyche 1:2')
    parts.should == {
      :nested => {
      :authors => ['Mayer, D.M.'],
      :title => 'Ants',
      :article => {
      :journal => 'Psyche',
      :series_volume_issue => '1',
      :pagination => '2',
    },
    :pages_in => 'Pp. 32-45 in',
    }
    }
  end

  it "should work on a slightly harder nesting" do
    parts = NestedCitationParser.parse 'Pp. 96-98 in: MacKay, W., Lowrie, D., Fisher, A., MacKay, E., Barnes, F., Lowrie, D.  The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae). New York: Harpers, 36 pp.'
    parts.should == {
      :nested => {
      :authors => ['MacKay, W.', 'Lowrie, D.', 'Fisher, A.', 'MacKay, E.', 'Barnes, F.', 'Lowrie, D.'],
      :title => 'The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae)',
      :book => {
      :publisher => {:name => 'Harpers', :place => 'New York'},
      :pagination => '36 pp.'
    },
      :pages_in => 'Pp. 96-98 in:',
    }
    }
  end

  it "should handle 'In:' (without pagination)" do
    parts = NestedCitationParser.parse 'In: MacKay, W. The ants. New York: Harpers, 36 pp.'
    parts[:nested].should include(:pages_in => 'In:')
  end

  it "should not crash when there's no year" do
    lambda {NestedCitationParser.parse 'Pp. 308-310 in: Johnson, R. A.; Overson, R. P. A new North American species of *Pogonomyrmex* (Hymenoptera: Formicidae) from the Mohave desert of eastern California and western Nevada. Journal of Hymenoptera Research 18:305-314.'}.should_not raise_error
  end

  it "should work when there's a space before the colon" do
    lambda {NestedCitationParser.parse(
      "Pp. 89-162 in : Hashimoto, Y.; Rahman, H. (eds.) Inventory and collection. Total protocol for understanding of biodiversity. Kota Kinabalu: Research and Education Component, BBEC Programme (Universiti Malaysia Sabah), 310 pp."
    )}.should_not raise_error
  end

  it "should work when there's a space before the colon" do
    lambda {NestedCitationParser.parse(
      "Pp. 268, 269-270 in: Wang, M., Xiao, G., Wu, J. Taxonomic studies on the genus *Tetramorium* Mayr in China (Hymenoptera, Formicidae). [In Chinese.] Forest Research 1:264-274."
    )}.should_not raise_error
  end

  it "should work when there are no authors" do
    parts = NestedCitationParser.parse(
      "Pp. 398-400 in: Atti della Terza Riunione degli Scienziati Italiani tenuta in Firenze nel settembre del 1841. Firenze: Galileiana, 791 pp."
    )
    parts.should == {
      :nested => {
      :authors => [],
      :title => 'Atti della Terza Riunione degli Scienziati Italiani tenuta in Firenze nel settembre del 1841',
      :book => {
      :publisher => {:name => 'Galileiana', :place => 'Firenze'},
      :pagination => '791 pp.',
    },
    :pages_in => 'Pp. 398-400 in:',
    }
    }
  end

  it "should handle 'P.'" do
    NestedCitationParser.parse(
      "P. 485-486 in: Collingwood, C. A.; Pohl, H.; Guesten, R.; Wranik, W.; van Harten, A. 2004. The ants (Insecta: Hymenoptera: Formicidae) of the Socotra Archipelago. Fauna of Arabia 20:473-495."
    ).should == {
      :nested => {
        :authors => ['Collingwood, C. A.', 'Pohl, H.', 'Guesten, R.', 'Wranik, W.', 'van Harten, A.'],
        :year => '2004',
        :title => 'The ants (Insecta: Hymenoptera: Formicidae) of the Socotra Archipelago',
        :article => {
          :journal => 'Fauna of Arabia',
          :series_volume_issue => '20',
          :pagination => '473-495',
        },
      :pages_in => 'P. 485-486 in:',
      }
    }
  end

  it "should handle different paginations" do
    NestedCitationParser.parse(
      "Pp. 63-396 (part) in: Baroni Urbani, C.; de Andrade, M. L. The ant genus Proceratium in the extant and fossil record (Hymenoptera: Formicidae). Museo Regionale di Scienze Naturali Monografie (Turin) 36:1-492.")[:nested][:pages_in].should == 'Pp. 63-396 (part) in:'
  end

  it "should handle a funky title containing periods in a certain journal" do
    NestedCitationParser.parse(
      "P. 391 in: Forel, A. Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-418").should == {
      :nested => {
        :pages_in => 'P. 391 in:',
        :authors => ['Forel, A.'],
        :title => 'Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc',
        :article => {
          :journal => 'Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien',
          :series_volume_issue => '58',
          :pagination => '340-418',
        },
      }
    }
  end

end
