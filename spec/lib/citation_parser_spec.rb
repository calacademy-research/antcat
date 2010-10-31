require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CitationParser do
  describe "parsing a book citation" do
    #it "should return nil if it doesn't seem to be a book citation" do
      #CitationParser.parse('Science 1:2').should be_nil
    #end

    it "should extract the place, pagination and publisher" do
      CitationParser.parse('Melbourne: CSIRO Publications, vii + 70 pp.').should == (
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
      )
    end

    it "should extract the place, pagination and publisher when there are multiple pagination sections" do
      CitationParser.parse('Melbourne: CSIRO Publications, vii, 70 pp.').should == (
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii, 70 pp.'}}
      )
    end

    it "should handle other variations in pagination" do
      ['1 p., 5 maps',
        '12 + 532 pp.',
        '24 pp. 24 pls.',
        '247 pp. + 14 pl. + 4 pp. (index)',
        '312 + (posthumous section) 95 pp.',
        '5-187 + i-viii pp.',
        '5 maps',
        '8 pls., 84 pp.',
        'i-ii, 279-655',
        'xi',
        '93-114, 121'
      ].each do |pagination|
        CitationParser.parse("Tokyo: Keishu-sha, #{pagination}").should ==(
          {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => pagination}}
        )
      end
    end

    it "should handle a publisher with a comma in its name" do
      CitationParser.parse('New York: Little, Brown, vii + 70 pp.').should == 
        {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
    end

    it "should handle a publisher with 'i' as a word in its name" do
      CitationParser.parse('Warszawa: Panstwowe Wydawnictwo Rolnicze i Lesne, 55 pp.').should ==
        {:book => {:publisher => {:name => 'Panstwowe Wydawnictwo Rolnicze i Lesne', :place => 'Warszawa'}, :pagination => '55 pp.'}}
    end
    
    it "should handle a publisher with a number in it" do
      CitationParser.parse(
        'Perth, Australia: Curtin University School of Environmental Biology (Bulletin No. 18), xii + 75 pp.'
      ).should ==
        {:book => {:publisher => {:name => 'Curtin University School of Environmental Biology (Bulletin No. 18)', :place => 'Perth, Australia'},
         :pagination => 'xii + 75 pp.'}}
    end
  end

  #describe "parsing a citation" do
    #it "should simply return an empty hash if there's no citation" do
      #['', nil].each {|citation| ReferenceParser.parse_citation(citation).should be_nil}
    #end
  #end

  #describe "parsing an unknown format" do
    #it "should consider it an 'other' reference" do
      #ReferenceParser.parse_unknown_citation('asdf').should == {:other => 'asdf'}
    #end
    #it "should remove the period from the end" do
      #ReferenceParser.parse_unknown_citation('asdf.').should == {:other => 'asdf'}
    #end
  #end

  #describe "parsing a nested citation" do
    #it "should return nil if it doesn't seem to be a nested citation" do
      #ReferenceParser.parse_nested_citation('Science 1:2').should be_nil
    #end

    #describe "parsing a nested citation" do
      #it "should handle parsing with no page numbers" do
        #ReferenceParser.parse_nested_citation(
          #'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.').
          #should ==
          #{:reference => {:authors => 'Michaelsen, W., Hartmeyer, R. (eds.)', :title => 'Die Fauna Sdwest-Australiens. Band I, Lieferung 7.',
           #:publisher => {:name => 'Gustav Fischer', :place => 'Jena'}, :pagination => 'pp. 263-310'}}
      #end

      #it "should handle parsing with page numbers" do
        #ReferenceParser.parse_nested_citation(
          #'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.').
          #should ==
          #{:other => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp'}
      #end

      #it "should handle parsing with page numbers when 'in' isn't followed by a colon" do
        #ReferenceParser.parse_nested_citation(
          #'Pp. 161-164 in Ganzhorn, J. U., Sorg, J.-P. (eds.) Ecology and economy of a tropical dry forest in Madagascar. Primate Report 46-1. Gttingen: German Primate Center (DPZ), 382 pp.').should ==
          #{:other => 'Pp. 161-164 in Ganzhorn, J. U., Sorg, J.-P. (eds.) Ecology and economy of a tropical dry forest in Madagascar. Primate Report 46-1. Gttingen: German Primate Center (DPZ), 382 pp'}
      #end

    #end
  #end
#end

end
