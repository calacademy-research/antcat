require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author do
  it "has many references" do
    author = Author.create! :name => 'Fisher, B.L.'

    reference = Factory(:reference)
    author.references << reference

    author.references.first.should == reference
  end

  describe "importing" do
    it "should create and return the authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name).should =~
      ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "should reuse existing authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.count.should == 2
    end
  end

  describe "editing" do
    it "should update associated references when the name is changed" do
      author = Factory :author, :name => 'Ward'
      reference = Factory :reference, :authors => [author]
      author.update_attribute :name, 'Fisher'
      reference.reload.authors_string.should == 'Fisher'
    end
  end

  describe "import_authors_string" do
    it "should find or create authors with names in the string" do
      Author.create! :name => 'Bolton, B.'
      author_data = Author.import_authors_string('Ward, P.S.; Bolton, B.')
      author_data[:authors].first.name.should == 'Ward, P.S.'
      author_data[:authors].second.name.should == 'Bolton, B.'
      author_data[:authors_suffix].should be_nil
      Author.count.should == 2
    end

    it "should return the authors suffix" do
      author_data = Author.import_authors_string('Ward, P.S.; Bolton, B. (eds.)')
      author_data[:authors].first.name.should == 'Ward, P.S.'
      author_data[:authors].second.name.should == 'Bolton, B.'
      author_data[:authors_suffix].should == ' (eds.)'
    end
  end

  describe "searching" do
    it "should find a prefix" do
      Author.create! :name => 'Bolton'
      Author.create! :name => 'Fisher'
      results = Author.search('Bol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should find an internal string" do
      Author.create! :name => 'Bolton'
      Author.create! :name => 'Fisher'
      results = Author.search('ol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should return authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        Author.create! :name => name
      end
      reference = Factory :reference, :authors => [Author.find_by_name('Most Recent')]
      AuthorParticipation.create! :created_at => Time.now - 5, :author => Author.find_by_name('Recent'), :reference => reference
      AuthorParticipation.create! :created_at => Time.now - 10, :author => Author.find_by_name('Old'), :reference => reference

      results = Author.search

      results.should == ['Most Recent', 'Recent', 'Old', 'Never Used']
    end
  end

  describe "first and last name" do
    it "should simply return the name if there's only one word" do
      author = Author.new :name => 'Bolton'
      author.last_name.should == 'Bolton'
      author.first_name_and_initials.should be_nil
    end
    it "should separate the words if there are multiple" do
      author = Author.new :name => 'Bolton, B.L.'
      author.last_name.should == 'Bolton'
      author.first_name_and_initials.should == 'B.L.'
    end
    it "should use all words if there is no comma" do
      author = Author.new :name => 'Royal Academy'
      author.last_name.should == 'Royal Academy'
      author.first_name_and_initials.should be_nil
    end
    it "should use use all words before the comma if there are multiple" do
      author = Author.new :name => 'Baroni Urbani, C.'
      author.last_name.should == 'Baroni Urbani'
      author.first_name_and_initials.should == 'C.'
    end
  end
end
