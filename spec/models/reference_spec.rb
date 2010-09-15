require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do

  describe "importing a new reference" do
    before do
      @reference_data = {
        :authors => ['Author'],
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :id => 1,
        :class => 'WardReference', 
      }
    end
    it "should import a book reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:book] = 1
      BookReference.should_receive(:import).with({
        :authors => [author],
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 1)
        Reference.import @reference_data
    end
    it "should import an article reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:article] = 1
      ArticleReference.should_receive(:import).with({
        :authors => [author],
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 1)
        Reference.import @reference_data
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      reference_factory(:author => 'Bolton')
      Reference.search(:author => 'foo').should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = reference_factory(:author => 'Bolton')
      reference_factory(:author => 'Fisher')
      Reference.search(:author => 'Bolton').should == [reference]
    end

    it "should find the reference for a given author prefix if it exists" do
      reference = reference_factory(:author => 'Bolton')
      reference_factory(:author => 'Fisher')
      Reference.search(:author => 'Bolt').should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author" do
      reference_factory(:author => 'Bolton', :citation_year => 2010)
      reference_factory(:author => 'Bolton', :citation_year => 1995)
      reference_factory(:author => 'Fisher', :citation_year => 2011)
      reference_factory(:author => 'Fisher', :citation_year => 1996)
      Reference.search(:start_year => '2012', :end_year => '2013', :author => 'Fisher').should be_empty
    end

    it "should return the one reference for a given year and author" do
      reference_factory(:author => 'Bolton', :citation_year => 2010)
      reference_factory(:author => 'Bolton', :citation_year => 1995)
      reference_factory(:author => 'Fisher', :citation_year => 2011)
      reference = reference_factory(:author => 'Fisher', :citation_year => 1996)
      Reference.search(:start_year => '1996', :end_year => '1996', :author => 'Fisher').should == [reference]
    end

    describe "searching by year" do
      before do
        reference_factory(:author => 'Bolton', :citation_year => 1994)
        reference_factory(:author => 'Bolton', :citation_year => 1995)
        reference_factory(:author => 'Bolton', :citation_year => 1996)
        reference_factory(:author => 'Bolton', :citation_year => 1997)
        reference_factory(:author => 'Bolton', :citation_year => 1998)
      end

      it "should return an empty array if nothing is found for year" do
        Reference.search(:start_year => '1992', :end_year => '1993').should be_empty
      end

      it "should find entries less than or equal to the end year" do
        Reference.search(:end_year => '1995').map(&:year).should =~ [1994, 1995]
      end

      it "should find entries equal to or greater than the start year" do
        Reference.search(:start_year => '1995').map(&:year).should =~ [1995, 1996, 1997, 1998]
      end

      it "should find entries in between the start year and the end year (inclusive)" do
        Reference.search(:start_year => '1995', :end_year => '1996').map(&:year).should =~ [1995, 1996]
      end

      it "should find references in the year of the end range, even if they have extra characters" do
        reference_factory(:author => 'Bolton', :citation_year => '2004.')
        Reference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ [2004]
      end

      it "should find references in the year of the start year, even if they have extra characters" do
        reference_factory(:author => 'Bolton', :citation_year => '2004.')
        Reference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ [2004]
      end

    end

    describe "sorting search results" do
      it "should sort by author plus year plus letter" do
        fisher1910b = reference_factory(:author => 'Fisher', :citation_year => '1910b')
        wheeler1874 = reference_factory(:author => 'Wheeler', :citation_year => '1874')
        fisher1910a = reference_factory(:author => 'Fisher', :citation_year => '1910a')

        results = Reference.search

        results.should == [fisher1910a, fisher1910b, wheeler1874]
      end

      it "should sort by multiple authors using their order in each reference" do
        v = ward_reference_factory(:authors => "Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.",
                                   :citation => 'Ants 1:1')
        a = ward_reference_factory(:authors => 'Abdalla, F. C.; Cruz-Landim, C. da.', :citation => 'Ants 2:2')
        m = ward_reference_factory(:authors => 'Mueller, U. G.; Mikheyev, A. S.; Abbot, P.', :citation => 'Ants 3:3')

        results = Reference.search

        results.should == [a, m, v]
      end
    end

    describe "searching by journal" do
      it "should find by journal" do
        reference = ward_reference_factory(:citation => "Mathematica 1:2")
        ward_reference_factory(:citation => "Ants Monthly 1:3")
        Reference.search(:journal => 'Mathematica').should == [reference]
      end
      it "should only do an exact match" do
        ward_reference_factory(:citation => "Mathematica 1:2")
        Reference.search(:journal => 'Math').should be_empty
      end
    end
  end

  it "has many authors" do
    reference = Reference.create! :title => 'asdf'

    author = Author.create! :name => 'Fisher, B.L.'
    reference.authors << author

    reference.authors.first.should == author
  end

  describe "authors_string" do
    before do
      @reference = Factory(:reference)
    end

    describe "formatting" do
      it "should be empty if there are no authors" do
        @reference.authors_string.should be_blank
      end

      it "should consist of one author if that's all there is" do
        @reference.authors << Factory(:author, :name => 'Fisher, B.L.')
        @reference.authors_string.should == 'Fisher, B.L.'
      end

      it "should separate multiple authors with semicolons" do
        @reference.authors << Factory(:author, :name => 'Fisher, B.L.')
        @reference.authors << Factory(:author, :name => 'Ward, P.S.')
        @reference.authors_string.should == 'Fisher, B.L.; Ward, P.S.'
      end
    end

    describe "updating, when things change" do
      it "should update its authors_string when an author is added" do
        @reference.authors_string.should be_blank
        @reference.authors << Factory(:author, :name => 'Ward')
        @reference.authors_string.should == 'Ward'
      end
      it "should update its authors_string when an author is removed" do
        @reference.authors << Factory(:author, :name => 'Ward')
        @reference.authors_string.should == 'Ward'
        @reference.authors = []
        @reference.authors_string.should be_blank
      end
      it "should update its authors_string when an author's name is changed" do
        author = Factory(:author, :name => 'Ward')
        @reference.authors << author
        @reference.authors_string.should == 'Ward'
        author.update_attribute :name, 'Fisher'
        @reference.reload.authors_string.should == 'Fisher'
      end
    end

    describe "maintaining its order" do
      it "should show the authors in the order in which they were added to the reference" do
        ward = Author.create!(:name => 'Ward')
        wilden = Author.create!(:name => 'Wilden')
        fisher = Author.create!(:name => 'Fisher')
        reference = Factory(:reference)
        reference.authors << wilden
        reference.authors << fisher
        reference.authors << ward
        reference.authors_string.should == 'Wilden; Fisher; Ward'
      end
    end
  end

  describe "validations" do
    it "validates that the title is present" do
      reference = Factory(:reference)
      reference.should be_valid
      reference.title = nil
      reference.should_not be_valid
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory(:reference, :citation_year => '1910a')
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe "polymorphic association to source of reference" do
    it "should work" do
      ward_reference = Factory(:ward_reference)
      reference = Reference.create! :source_reference => ward_reference, :title => 'asdf'
      reference.reload.source_reference.should == ward_reference
    end
  end

end
