require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do

  describe "importing a new reference" do
    it "should import a book reference" do
      data = {:year => 2010, :book => {}}
      BookReference.should_receive(:import).with(data)
      Reference.import data
    end
    it "should import an article reference" do
      data = {:year => 2010, :article => {}}
      ArticleReference.should_receive(:import).with(data)
      Reference.import data
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      Factory(:reference, :authors => 'Bolton')
      Reference.search(:author => 'foo').should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = Factory(:reference, :authors => 'Bolton')
      Factory(:reference, :authors => 'Fisher')
      Reference.search(:author => 'Bolton').should == [reference]
    end

    it "should find the reference for a given author prefix if it exists" do
      reference = Factory(:reference, :authors => 'Bolton')
      Factory(:reference, :authors => 'Fisher')
      Reference.search(:author => 'Bolt').should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author" do
      Factory(:reference, :authors => 'Bolton', :year => 2010)
      Factory(:reference, :authors => 'Bolton', :year => 1995)
      Factory(:reference, :authors => 'Fisher', :year => 2011)
      Factory(:reference, :authors => 'Fisher', :year => 1996)
      Reference.search(:start_year => '2012', :end_year => '2013', :author => 'Fisher').should be_empty
    end

    it "should return the one reference for a given year and author" do
      Factory(:reference, :authors => 'Bolton', :year => 2010)
      Factory(:reference, :authors => 'Bolton', :year => 1995)
      Factory(:reference, :authors => 'Fisher', :year => 2011)
      reference = Factory(:reference, :authors => 'Fisher', :year => 1996)
      Reference.search(:start_year => '1996', :end_year => '1996', :author => 'Fisher').should == [reference]
    end

    describe "searching by year" do
      before do
        Factory(:reference, :year => 1994)
        Factory(:reference, :year => 1995)
        Factory(:reference, :year => 1996)
        Factory(:reference, :year => 1997)
        Factory(:reference, :year => 1998)
      end

      it "should return an empty array if nothing is found for year" do
        Reference.search(:start_year => '1992', :end_year => '1993').should be_empty
      end

      it "should find entries less than or equal to the end year" do
        Reference.search(:end_year => '1995').map(&:year).should =~ ['1994', '1995']
      end

      it "should find entries equal to or greater than the start year" do
        Reference.search(:start_year => '1995').map(&:year).should =~ ['1995', '1996', '1997', '1998']
      end

      it "should find entries in between the start year and the end year (inclusive)" do
        Reference.search(:start_year => '1995', :end_year => '1996').map(&:year).should =~ ['1995', '1996']
      end

      it "should find references in the year of the end range, even if they have extra characters" do
        Factory(:reference, :year => '2004.', :year => 2004)
        Reference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ ['2004']
      end

      it "should find references in the year of the start year, even if they have extra characters" do
        Factory(:reference, :year => '2004.', :year => 2004)
        Reference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ ['2004']
      end

    end
    
    describe "sorting search results" do
      it "should sort by author plus year plus letter" do
        fisher1910b = Factory(:reference, :authors => 'Fisher', :year => '1910b')
        wheeler1874 = Factory(:reference, :authors => 'Wheeler', :year => '1874')
        fisher1910a = Factory(:reference, :authors => 'Fisher', :year => '1910a')

        results = Reference.search

        results.should == [fisher1910a, fisher1910b, wheeler1874]
      end
    end

    describe "searching by journal" do
      it "should find by journal" do
        reference = Factory(:reference, :citation => "Mathematica 1:2")
        Factory(:reference, :citation => "Ants Monthly 1:3")
        Reference.search(:journal => 'Mathematica').should == [reference]
      end
      it "should only do an exact match" do
        Factory(:reference, :citation => "Mathematica 1:2")
        Reference.search(:journal => 'Math').should be_empty
      end
    end
  end

  it "has many authors" do
    reference = Reference.create!

    author = Author.create! :name => 'Fisher, B.L.'
    reference.authors << author

    reference.authors.first.should == author
  end

end
