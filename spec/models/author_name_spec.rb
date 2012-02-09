# coding: UTF-8
require 'spec_helper'

describe AuthorName do
  before do
    @author = Author.create!
  end

  it "has many references" do
    author_name = AuthorName.create! :name => 'Fisher, B.L.', :author => @author

    reference = Factory(:reference)
    author_name.references << reference

    author_name.references.first.should == reference
  end

  it "has an author" do
    author = Author.create!
    AuthorName.create! :author => author, :name => 'Fisher, B.L.', :author => @author
  end

  it "must have an author" do
    author_name = AuthorName.new :name => 'Ward, P. S.'
    author_name.should_not be_valid
    author_name.author = Factory :author
    author_name.should be_valid
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

    it "should respect case" do
      AuthorName.import(['Mackay, W. M.', 'MacKay, W. M.'])
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
      AuthorName.create! :name => 'Bolton, B.', :author => @author
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

    it "should handle the Andres" do
      author_data = AuthorName.import_author_names_string('Andre, Edm.; Andre, Ern.')
      author_data[:author_names].first.name.should == 'Andre, Edm.'
      author_data[:author_names].second.name.should == 'Andre, Ern.'
    end

    it "should not just crap out when the input is invalid" do
      author_data = AuthorName.import_author_names_string(' ; ')
      author_data[:author_names].should == []
      author_data[:author_names_suffix].should be_nil
    end

   it "should handle a semicolon followed by a space at the end" do
     author_data = AuthorName.import_author_names_string('Ward, P. S.; ')
     author_data[:author_names].should have(1).item
     author_data[:author_names].first.name.should == 'Ward, P. S.'
     author_data[:author_names_suffix].should be_nil
   end

  end

  describe "searching" do
    it "should find a prefix" do
      AuthorName.create! :name => 'Bolton', :author => @author
      AuthorName.create! :name => 'Fisher', :author => @author
      results = AuthorName.search('Bol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should find an internal string" do
      AuthorName.create! :name => 'Bolton', :author => @author
      AuthorName.create! :name => 'Fisher', :author => @author
      results = AuthorName.search('ol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should return authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        AuthorName.create! :name => name, :author => @author
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
      author = AuthorName.create! :name => 'Ward, P. S., Jr.', :author => @author
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P. S., Jr.'
    end
    it "should not mess with missing space before hyphen" do
      author = AuthorName.create! :name => 'Ward, P.-S.', :author => @author
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P.-S.'
    end
    it "should find and fix the author names with missing spaces and fix them" do
      author = AuthorName.create! :name => 'Ward, P.S.', :author => @author
      AuthorName.fix_missing_spaces
      author.reload.name.should == 'Ward, P. S.'
    end
    it "should find an existing author that has the space and transfer references to it" do
      ward_with_spaces = AuthorName.create! :name => 'Ward, P. S.', :author => @author
      ward_without_spaces = AuthorName.create! :name => 'Ward, P.S.', :author => @author
      reference = Factory :reference, :author_names => [ward_without_spaces]
      AuthorName.fix_missing_spaces
      reference.author_names(true).should == [ward_with_spaces]
      AuthorName.count.should == 1
    end
  end

  describe "create aliases for names differing only in hyphenation" do
    it "should change author to nonhyphenated one's author" do
      with_hyphen = Factory :author_name, :name => 'Ward, P.-S.'
      without_hyphen = Factory :author_name, :name => 'Ward, P. S.'
      reference = Factory :reference, :author_names => [without_hyphen]
      AuthorName.create_hyphenation_aliases
      author = reference.authors(true).first
      author.names.should =~ [with_hyphen, without_hyphen]
    end
    it "should do nothing if the author is already the same as the nonhyphenated one's author" do
      author = Factory :author
      with_hyphen = Factory :author_name, :name => 'Ward, P.-S.', :author => author
      without_hyphen = Factory :author_name, :name => 'Ward, P. S.', :author => author
      reference = Factory :reference, :author_names => [without_hyphen]
      AuthorName.create_hyphenation_aliases
      with_hyphen.reload.author.reload.should == author
      without_hyphen.reload.author.reload.should == author
    end
  end

  describe "aliasing" do
    it "should create aliases between all the provided names and delete the extra authors" do
      Author.delete_all
      Factory :author_name, :name => 'Ward, P. S.'
      Factory :author_name, :name => 'Ward, Phil'
      AuthorName.alias false, 'Ward, P. S.', 'Ward, Phil'
      AuthorName.find_by_name('Ward, P. S.').author.should == AuthorName.find_by_name('Ward, Phil').author
      Author.count.should == 1
    end
    it "should handle the situation where none of the authors exist yet" do
      Author.delete_all
      AuthorName.alias false, 'Ward, P. S.', 'Ward, Phil'
      AuthorName.find_by_name('Ward, P. S.').author.should == AuthorName.find_by_name('Ward, Phil').author
      Author.count.should == 1
    end
    it "should not mess about aliases that are already there" do
      Author.delete_all
      martinez_ibanez = Author.create!
      AuthorName.create! :name => 'Martínez Ibáñez, M. D.', :author => martinez_ibanez
      AuthorName.create! :name => 'Martínez-Ibáñez, M. D.', :author => martinez_ibanez
      Factory :author_name, :name => 'Martínez-Ibañez, D.'
      AuthorName.alias false, "Martínez Ibáñez, M. D.", "Martínez-Ibañez, D.", "Martínez-Ibáñez, M. D."
      Author.count.should == 1
      author = AuthorName.find_by_name("Martínez Ibáñez, M. D.").author 
      author.should == AuthorName.find_by_name("Martínez-Ibañez, D.").author 
      author.should == AuthorName.find_by_name("Martínez-Ibáñez, M. D.").author 
    end
  end

  describe "correcting" do
    describe "when the correct name doesn't exist" do
      it "should add the correct name, delete the old name, and update its reference's" do
        Author.delete_all
        reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Ward, Phil')]
        AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
        AuthorName.find_by_name('Ward, Phil').should be_nil
        reference.reload
        reference.author_names.map(&:name).should == ['Ward, P. S.']
        reference.author_names_string.should == 'Ward, P. S.'
      end
    end
    describe "when the correct name does exist" do
      it "should add the correct name, delete the old name, and update its references" do
        Author.delete_all
        Factory :author_name, :name => 'Ward, P. S.'
        reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Ward, Phil')]
        AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
        AuthorName.find_by_name('Ward, Phil').should be_nil
        reference.reload
        reference.author_names.map(&:name).should == ['Ward, P. S.']
        reference.author_names_string.should == 'Ward, P. S.'
        AuthorName.count.should == 1
        Author.count.should == 1
      end
      describe "when the correct name does exist and it has other names" do
        it "shouldn't delete the author" do
          Author.delete_all
          author = Factory :author
          good = Factory :author_name, :name => 'Ward, P. S.', :author => author
          bad = Factory :author_name, :name => 'Ward, Phil', :author => author
          reference = Factory :reference, :author_names => [bad]
          AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
          AuthorName.find_by_name('Ward, Phil').should be_nil
          AuthorName.find_by_name('Ward, P. S.').author.should == author
          AuthorName.count.should == 1
          Author.count.should == 1
        end
      end
    end
  end

  describe "finding preposition synonyms" do
    ['Le', 'La', 'De'].each do |preposition|
      it "should find names that differ only in having a space after the initial #{preposition}" do
        no_space = Factory :author_name, :name => "#{preposition}farge, M."
        with_space = Factory :author_name, :name => "#{preposition} Farge, M."
        Factory :author_name, :name => "#{preposition}me, M."
        AuthorName.find_preposition_synonyms.should == [[with_space, no_space]]
      end
    end
    it "should find names that differ only in having a preposition in the back instead of the front" do
      in_front = Factory :author_name, :name => "La Farge, M."
      in_back = Factory :author_name, :name => "Farge, M., La"
      Factory :author_name, :name => "me, M., La"
      AuthorName.find_preposition_synonyms.should == [[in_front, in_back]]
    end
  end

end
