require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookParser do
  describe "parsing a book citation" do
    it "should return nil if it doesn't seem to be a book citation" do
      BookParser.parse('Science 1:2').should be_nil
    end

    it "should extract the place, pagination and publisher" do
      BookParser.parse('Melbourne: CSIRO Publications, vii + 70 pp.').should == (
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
      )
    end

    it "should extract the place, pagination and publisher when there are multiple pagination sections" do
      BookParser.parse('Melbourne: CSIRO Publications, vii, 70 pp.').should == (
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
        BookParser.parse("Tokyo: Keishu-sha, #{pagination}").should ==(
          {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => pagination}}
        )
      end
    end

    it "should handle a publisher with a comma in its name" do
      BookParser.parse('New York: Little, Brown, vii + 70 pp.').should == 
        {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
    end

    it "should handle a publisher with 'i' as a word in its name" do
      BookParser.parse('Warszawa: Panstwowe Wydawnictwo Rolnicze i Lesne, 55 pp.').should ==
        {:book => {:publisher => {:name => 'Panstwowe Wydawnictwo Rolnicze i Lesne', :place => 'Warszawa'}, :pagination => '55 pp.'}}
    end
    
    it "should handle a publisher with a number in it" do
      BookParser.parse(
        'Perth, Australia: Curtin University School of Environmental Biology (Bulletin No. 18), xii + 75 pp.'
      ).should ==
        {:book => {:publisher => {:name => 'Curtin University School of Environmental Biology (Bulletin No. 18)', :place => 'Perth, Australia'},
         :pagination => 'xii + 75 pp.'}}
    end
  end
end
