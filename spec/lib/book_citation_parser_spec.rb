require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookCitationParser do
  describe "parsing a book citation" do
    it "should return nil if it doesn't seem to be a book citation" do
      BookCitationParser.parse('Science 1:2').should be_nil
    end

    it "should extract the place, pagination and publisher" do
      BookCitationParser.parse('Melbourne: CSIRO Publications, vii + 70 pp.').should == (
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
      )
    end

    it "should extract the place, pagination and publisher when there are multiple pagination sections" do
      BookCitationParser.parse('Melbourne: CSIRO Publications, vii, 70 pp.').should == (
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
        '93-114, 121',
        'P. 1'
      ].each do |pagination|
        BookCitationParser.parse("Tokyo: Keishu-sha, #{pagination}").should ==(
          {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => pagination}}
        )
      end
    end

    it "should handle a publisher with a comma in its name" do
      BookCitationParser.parse('New York: Little, Brown, vii + 70 pp.').should == 
        {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
    end

    it "should handle a publisher with 'i' as a word in its name" do
      BookCitationParser.parse('Warszawa: Panstwowe Wydawnictwo Rolnicze i Lesne, 55 pp.').should ==
        {:book => {:publisher => {:name => 'Panstwowe Wydawnictwo Rolnicze i Lesne', :place => 'Warszawa'}, :pagination => '55 pp.'}}
    end
    
    it "should handle a publisher with a number in it" do
      BookCitationParser.parse(
        'Perth, Australia: Curtin University School of Environmental Biology (Bulletin No. 18), xii + 75 pp.'
      ).should ==
        {:book => {:publisher => {:name => 'Curtin University School of Environmental Biology (Bulletin No. 18)', :place => 'Perth, Australia'},
         :pagination => 'xii + 75 pp.'}}
    end

    it "should handle a title with a colon in it (i.e., shouldn't think it's a book just because of that)" do
      BookCitationParser.parse(
"Six new weaver ant species from Malaysia: *Camponotus *(*Karavaievia*) *striatipes*, *C.* (*K.*) *melanus*, *C.* (*K.*) *nigripes*, *C.* (*K.*) *belumensis*, *C.* (*K.*) *gentingensis*, and *C.* (*K.*) *micragyne*. Malaysian Journal of Science. Series A. Life Sciences 16:87-105."
      ).should be_nil
    end

  end
end
