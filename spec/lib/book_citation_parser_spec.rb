require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookCitationParser do
  before :all do
    Factory :place, :name => 'New York'
  end

  it "should return nil if it doesn't seem to be a book citation" do
    BookCitationParser.parse('Science 1:2', false).should be_nil
  end

  describe "different behavior when possibly embedded (i.e., preceded by a title)" do
    it 'should recognize an unembedded book citation' do
      BookCitationParser.parse('New York: Wiley, 2 pp.', true).should have_key(:book)
    end
    it 'should recognize an embedded book citation when the place has no periods' do
      BookCitationParser.parse('New York: Wiley, 2 pp.', true).should have_key(:book)
    end
    it 'should not recognize an embedded book citation when the place has a period' do
      BookCitationParser.parse('St. Croix: Wiley, 2 pp.', true).should be_false
    end
    it 'should recognize an unembedded book citation when the place has a period' do
      BookCitationParser.parse('St. Croix: Wiley, 2 pp.', false).should have_key(:book)
    end
    it 'should recognize an embedded book citation when the place has a period and the place is known' do
      Place.create! :name => 'St. Croix'
      BookCitationParser.parse('St. Croix: Wiley, 2 pp.', true).should have_key(:book)
    end
  end

  it "should extract the place, pagination and publisher" do
    BookCitationParser.parse('New York: CSIRO Publications, vii + 70 pp.', false).should == (
      {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
    )
  end

  it "should extract the place, pagination and publisher when there are multiple pagination sections" do
    BookCitationParser.parse('New York: CSIRO Publications, vii, 70 pp.', false).should == (
      {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'New York'}, :pagination => 'vii, 70 pp.'}}
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
      'P. 1',
      '32pp.',
      '32 pp.',
    ].each do |pagination|
      BookCitationParser.parse("New York: Keishu-sha, #{pagination}", false).should ==(
        {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'New York'}, :pagination => pagination}}
      )
    end
  end

  it "should handle a publisher with a comma in its name" do
    BookCitationParser.parse('New York: Little, Brown, vii + 70 pp.', false).should == 
      {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
  end

  it "should handle a citation with no space after the colon" do
    BookCitationParser.parse('New York:Little, Brown, vii + 70 pp.', false).should == 
      {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
  end

  it "should handle a publisher with 'i' as a word in its name" do
    BookCitationParser.parse('New York: Panstwowe Wydawnictwo Rolnicze i Lesne, 55 pp.', false).should ==
      {:book => {:publisher => {:name => 'Panstwowe Wydawnictwo Rolnicze i Lesne', :place => 'New York'}, :pagination => '55 pp.'}}
  end
  
  it "should handle a place with a number in it" do
    Place.create! :name => 'Perth, Australia'
    BookCitationParser.parse(
      'Perth, Australia: Curtin University School of Environmental Biology (Bulletin No. 18), xii + 75 pp.', false
    ).should ==
      {:book => {:publisher => {:name => 'Curtin University School of Environmental Biology (Bulletin No. 18)', :place => 'Perth, Australia'},
        :pagination => 'xii + 75 pp.'}}
  end

  it "should handle a title with a colon in it (i.e., shouldn't think it's a book just because of that)" do
    BookCitationParser.parse(
"Six new weaver ant species from Malaysia: *Camponotus *(*Karavaievia*) *striatipes*, *C.* (*K.*) *melanus*, *C.* (*K.*) *nigripes*, *C.* (*K.*) *belumensis*, *C.* (*K.*) *gentingensis*, and *C.* (*K.*) *micragyne*. Malaysian Journal of Science. Series A. Life Sciences 16:87-105.", false
    ).should be_nil
  end

  it "should not be fooled by a colon that is part of a pagination note" do
    BookCitationParser.parse("Journal of Insect Science 7(42), 14 pp. (available online: insectscience.org/7.42).", false).should be_nil
  end

end
