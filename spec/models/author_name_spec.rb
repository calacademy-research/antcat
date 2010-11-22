require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthorName do
  it "has many references" do
    author_name = AuthorName.create! :name => 'Fisher, B.L.'

    reference = Factory(:reference)
    author_name.references << reference

    author_name.references.first.should == reference
  end

  it "has an author" do
    author = Author.create!
    AuthorName.create! :author => author, :name => 'Fisher, B.L.'
  end

  describe "importing" do
    it "should create and return the authors" do
      AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name).should =~
      ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "should reuse existing authors" do
      AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      AuthorName.count.should == 2
    end
  end

  describe "editing" do
    it "should update associated references when the name is changed" do
      author_name = Factory :author_name, :name => 'Ward'
      reference = Factory :reference, :author_names => [author_name]
      author_name.update_attribute :name, 'Fisher'
      reference.reload.author_names_string.should == 'Fisher'
    end
  end

  describe "import_author_names_string" do
    it "should find or create authors with names in the string" do
      AuthorName.create! :name => 'Bolton, B.'
      author_data = AuthorName.import_author_names_string('Ward, P.S.; Bolton, B.')
      author_data[:author_names].first.name.should == 'Ward, P.S.'
      author_data[:author_names].second.name.should == 'Bolton, B.'
      author_data[:author_names_suffix].should be_nil
      AuthorName.count.should == 2
    end

    it "should return the authors suffix" do
      author_data = AuthorName.import_author_names_string('Ward, P.S.; Bolton, B. (eds.)')
      author_data[:author_names].first.name.should == 'Ward, P.S.'
      author_data[:author_names].second.name.should == 'Bolton, B.'
      author_data[:author_names_suffix].should == ' (eds.)'
    end
  end

  describe "searching" do
    it "should find a prefix" do
      AuthorName.create! :name => 'Bolton'
      AuthorName.create! :name => 'Fisher'
      results = AuthorName.search('Bol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should find an internal string" do
      AuthorName.create! :name => 'Bolton'
      AuthorName.create! :name => 'Fisher'
      results = AuthorName.search('ol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should return authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        AuthorName.create! :name => name
      end
      reference = Factory :reference, :author_names => [AuthorName.find_by_name('Most Recent')]
      ReferenceAuthorName.create! :created_at => Time.now - 5, :author_name => AuthorName.find_by_name('Recent'),
                                  :reference => reference
      ReferenceAuthorName.create! :created_at => Time.now - 10, :author_name => AuthorName.find_by_name('Old'),
                                  :reference => reference
      AuthorName.search.should == ['Most Recent', 'Recent', 'Old', 'Never Used']
    end
  end

  describe "first and last name" do
    it "should simply return the name if there's only one word" do
      author_name = AuthorName.new :name => 'Bolton'
      author_name.last_name.should == 'Bolton'
      author_name.first_name_and_initials.should be_nil
    end
    it "should separate the words if there are multiple" do
      author_name = AuthorName.new :name => 'Bolton, B.L.'
      author_name.last_name.should == 'Bolton'
      author_name.first_name_and_initials.should == 'B.L.'
    end
    it "should use all words if there is no comma" do
      author_name = AuthorName.new :name => 'Royal Academy'
      author_name.last_name.should == 'Royal Academy'
      author_name.first_name_and_initials.should be_nil
    end
    it "should use use all words before the comma if there are multiple" do
      author_name = AuthorName.new :name => 'Baroni Urbani, C.'
      author_name.last_name.should == 'Baroni Urbani'
      author_name.first_name_and_initials.should == 'C.'
    end
  end

  describe "fixing missing space after periods" do
    it "should not mess with missing space before comma" do
      author = AuthorName.create! :name => 'Ward, P. S., Jr.'
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P. S., Jr.'
    end
    it "should not mess with missing space before hyphen" do
      author = AuthorName.create! :name => 'Ward, P.-S.'
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P.-S.'
    end
    it "should find and fix the author names with missing spaces and fix them" do
      author = AuthorName.create! :name => 'Ward, P.S.'
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P. S.'
    end
    it "should find an existing author that has the space and transfer references to it" do
      ward_with_spaces = AuthorName.create! :name => 'Ward, P. S.'
      ward_without_spaces = AuthorName.create! :name => 'Ward, P.S.'
      reference = Factory :reference, :author_names => [ward_without_spaces]
      AuthorName.fix_missing_spaces true
      reference.author_names(true).should == [ward_with_spaces]
      AuthorName.count.should == 1
    end
  end
end
