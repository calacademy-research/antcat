# coding: UTF-8
require 'spec_helper'

describe AuthorName do
  before do
    @author = Author.create!
  end

  it "has many references" do
    author_name = AuthorName.create! :name => 'Fisher, B.L.', :author => @author

    reference = FactoryGirl.create(:reference)
    author_name.references << reference

    expect(author_name.references.first).to eq(reference)
  end

  it "has an author" do
    author = Author.create!
    AuthorName.create! :author => author, :name => 'Fisher, B.L.', :author => @author
  end

  it "must have an author" do
    author_name = AuthorName.new :name => 'Ward, P. S.'
    expect(author_name).not_to be_valid
    author_name.author = FactoryGirl.create :author
    expect(author_name).to be_valid
  end

  it "can't be blank" do
    author_name = AuthorName.new
    author_name.author = FactoryGirl.create :author
    author_name.name = nil
    expect(author_name).not_to be_valid
    author_name.name = ''
    expect(author_name).not_to be_valid
    author_name.name = 'Bolton, B.'
    expect(author_name).to be_valid
  end

  it "can't be a duplicate" do
    author_name = FactoryGirl.create :author_name, name: 'Bolton'
    author_name.author = FactoryGirl.create :author
    author_name.save!

    author_name = FactoryGirl.build :author_name, name: 'Bolton'
    expect(author_name).not_to be_valid
  end

  describe "importing" do
    it "should create and return the authors" do
      expect(AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name)).to match_array(
      ['Fisher, B.L.', 'Wheeler, W.M.']
      )
    end

    it "should reuse existing authors" do
      AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      AuthorName.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      expect(AuthorName.count).to eq(2)
    end

    it "should respect case" do
      AuthorName.import(['Mackay, W. M.', 'MacKay, W. M.'])
      expect(AuthorName.count).to eq(2)
    end
  end

  describe "editing" do
    it "should update associated references when the name is changed" do
      author_name = FactoryGirl.create :author_name, :name => 'Ward'
      reference = FactoryGirl.create :reference, :author_names => [author_name]
      author_name.update_attribute :name, 'Fisher'
      expect(Reference.find(reference.id).author_names_string).to eq('Fisher')
    end
  end

  describe "import_author_names_string" do
    it "should find or create authors with names in the string" do
      AuthorName.create! :name => 'Bolton, B.', :author => @author
      author_data = AuthorName.import_author_names_string('Ward, P.S.; Bolton, B.')
      expect(author_data[:author_names].first.name).to eq('Ward, P.S.')
      expect(author_data[:author_names].second.name).to eq('Bolton, B.')
      expect(author_data[:author_names_suffix]).to be_nil
      expect(AuthorName.count).to eq(2)
    end

    it "should return the authors suffix" do
      author_data = AuthorName.import_author_names_string('Ward, P.S.; Bolton, B. (eds.)')
      expect(author_data[:author_names].first.name).to eq('Ward, P.S.')
      expect(author_data[:author_names].second.name).to eq('Bolton, B.')
      expect(author_data[:author_names_suffix]).to eq(' (eds.)')
    end

    it "should handle the Andres" do
      author_data = AuthorName.import_author_names_string('Andre, Edm.; Andre, Ern.')
      expect(author_data[:author_names].first.name).to eq('Andre, Edm.')
      expect(author_data[:author_names].second.name).to eq('Andre, Ern.')
    end

    it "should not just crap out when the input is invalid" do
      author_data = AuthorName.import_author_names_string(' ; ')
      expect(author_data[:author_names]).to eq([])
      expect(author_data[:author_names_suffix]).to be_nil
    end

   it "should handle a semicolon followed by a space at the end" do
     author_data = AuthorName.import_author_names_string('Ward, P. S.; ')
     expect(author_data[:author_names].size).to eq(1)
     expect(author_data[:author_names].first.name).to eq('Ward, P. S.')
     expect(author_data[:author_names_suffix]).to be_nil
   end

  end

  describe "searching" do
    it "should find a prefix" do
      AuthorName.create! :name => 'Bolton', :author => @author
      AuthorName.create! :name => 'Fisher', :author => @author
      results = AuthorName.search('Bol')
      expect(results.count).to eq(1)
      expect(results.first).to eq('Bolton')
    end

    it "should find an internal string" do
      AuthorName.create! :name => 'Bolton', :author => @author
      AuthorName.create! :name => 'Fisher', :author => @author
      results = AuthorName.search('ol')
      expect(results.count).to eq(1)
      expect(results.first).to eq('Bolton')
    end

    it "should return authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        AuthorName.create! :name => name, :author => @author
      end
      reference = FactoryGirl.create :reference, :author_names => [AuthorName.find_by_name('Most Recent')]
      ReferenceAuthorName.create! :created_at => Time.now - 5, :author_name => AuthorName.find_by_name('Recent'),
                                  :reference => reference
      ReferenceAuthorName.create! :created_at => Time.now - 10, :author_name => AuthorName.find_by_name('Old'),
                                  :reference => reference
      expect(AuthorName.search).to eq(['Most Recent', 'Recent', 'Old', 'Never Used'])
    end
  end

  describe "first and last name" do
    it "should simply return the name if there's only one word" do
      author_name = AuthorName.new :name => 'Bolton'
      expect(author_name.last_name).to eq('Bolton')
      expect(author_name.first_name_and_initials).to be_nil
    end
    it "should separate the words if there are multiple" do
      author_name = AuthorName.new :name => 'Bolton, B.L.'
      expect(author_name.last_name).to eq('Bolton')
      expect(author_name.first_name_and_initials).to eq('B.L.')
    end
    it "should use all words if there is no comma" do
      author_name = AuthorName.new :name => 'Royal Academy'
      expect(author_name.last_name).to eq('Royal Academy')
      expect(author_name.first_name_and_initials).to be_nil
    end
    it "should use use all words before the comma if there are multiple" do
      author_name = AuthorName.new :name => 'Baroni Urbani, C.'
      expect(author_name.last_name).to eq('Baroni Urbani')
      expect(author_name.first_name_and_initials).to eq('C.')
    end
  end

  describe "fixing missing space after periods" do
    it "should not mess with missing space before comma" do
      author = AuthorName.create! :name => 'Ward, P. S., Jr.', :author => @author
      AuthorName.fix_missing_spaces
      expect(AuthorName.find(author).name).to eq('Ward, P. S., Jr.')
    end
    it "should not mess with missing space before hyphen" do
      author = AuthorName.create! :name => 'Ward, P.-S.', :author => @author
      AuthorName.fix_missing_spaces
      expect(AuthorName.find(author).name).to eq('Ward, P.-S.')
    end
    it "should find and fix the author names with missing spaces and fix them" do
      author = AuthorName.create! :name => 'Ward, P.S.', :author => @author
      AuthorName.fix_missing_spaces
      expect(AuthorName.find(author).name).to eq('Ward, P. S.')
    end
    it "should find an existing author that has the space and transfer references to it" do
      ward_with_spaces = AuthorName.create! :name => 'Ward, P. S.', :author => @author
      ward_without_spaces = AuthorName.create! :name => 'Ward, P.S.', :author => @author
      reference = FactoryGirl.create :reference, :author_names => [ward_without_spaces]
      AuthorName.fix_missing_spaces
      expect(reference.author_names(true)).to eq([ward_with_spaces])
      expect(AuthorName.count).to eq(1)
    end
  end

  describe "create aliases for names differing only in hyphenation" do
    it "should change author to nonhyphenated one's author" do
      with_hyphen = FactoryGirl.create :author_name, :name => 'Ward, P.-S.'
      without_hyphen = FactoryGirl.create :author_name, :name => 'Ward, P. S.'
      reference = FactoryGirl.create :reference, :author_names => [without_hyphen]
      AuthorName.create_hyphenation_aliases
      author = reference.authors(true).first
      expect(author.names).to match_array([with_hyphen, without_hyphen])
    end
    it "should do nothing if the author is already the same as the nonhyphenated one's author" do
      author = FactoryGirl.create :author
      with_hyphen = FactoryGirl.create :author_name, :name => 'Ward, P.-S.', :author => author
      without_hyphen = FactoryGirl.create :author_name, :name => 'Ward, P. S.', :author => author
      reference = FactoryGirl.create :reference, :author_names => [without_hyphen]
      AuthorName.create_hyphenation_aliases
      expect(Author.find(AuthorName.find(with_hyphen).author)).to eq(author)
      expect(Author.find(AuthorName.find(without_hyphen).author)).to eq(author)
    end
  end

  describe "aliasing" do
    it "should create aliases between all the provided names and delete the extra authors" do
      Author.delete_all
      FactoryGirl.create :author_name, :name => 'Ward, P. S.'
      FactoryGirl.create :author_name, :name => 'Ward, Phil'
      AuthorName.alias false, 'Ward, P. S.', 'Ward, Phil'
      expect(AuthorName.find_by_name('Ward, P. S.').author).to eq(AuthorName.find_by_name('Ward, Phil').author)
      expect(Author.count).to eq(1)
    end
    it "should handle the situation where none of the authors exist yet" do
      Author.delete_all
      AuthorName.alias false, 'Ward, P. S.', 'Ward, Phil'
      expect(AuthorName.find_by_name('Ward, P. S.').author).to eq(AuthorName.find_by_name('Ward, Phil').author)
      expect(Author.count).to eq(1)
    end
    it "should not mess about aliases that are already there" do
      Author.delete_all
      martinez_ibanez = Author.create!
      AuthorName.create! :name => 'Martínez Ibáñez, M. D.', :author => martinez_ibanez
      AuthorName.create! :name => 'Martínez-Ibáñez, M. D.', :author => martinez_ibanez
      FactoryGirl.create :author_name, :name => 'Martínez-Ibañez, D.'
      AuthorName.alias false, "Martínez Ibáñez, M. D.", "Martínez-Ibañez, D.", "Martínez-Ibáñez, M. D."
      expect(Author.count).to eq(1)
      author = AuthorName.find_by_name("Martínez Ibáñez, M. D.").author
      expect(author).to eq(AuthorName.find_by_name("Martínez-Ibañez, D.").author)
      expect(author).to eq(AuthorName.find_by_name("Martínez-Ibáñez, M. D.").author)
    end
  end

  describe "correcting" do
    describe "when the correct name doesn't exist" do
      it "should add the correct name, delete the old name, and update its reference's" do
        Author.delete_all
        reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Ward, Phil')]
        AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
        expect(AuthorName.find_by_name('Ward, Phil')).to be_nil
        reference = Reference.find reference
        expect(reference.author_names.map(&:name)).to eq(['Ward, P. S.'])
        expect(reference.author_names_string).to eq('Ward, P. S.')
      end
    end
    describe "when the correct name does exist" do
      it "should add the correct name, delete the old name, and update its references" do
        Author.delete_all
        FactoryGirl.create :author_name, :name => 'Ward, P. S.'
        reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Ward, Phil')]
        AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
        expect(AuthorName.find_by_name('Ward, Phil')).to be_nil
        reference = Reference.find reference
        expect(reference.author_names.map(&:name)).to eq(['Ward, P. S.'])
        expect(reference.author_names_string).to eq('Ward, P. S.')
        expect(AuthorName.count).to eq(1)
        expect(Author.count).to eq(1)
      end
      describe "when the correct name does exist and it has other names" do
        it "shouldn't delete the author" do
          Author.delete_all
          author = FactoryGirl.create :author
          good = FactoryGirl.create :author_name, :name => 'Ward, P. S.', :author => author
          bad = FactoryGirl.create :author_name, :name => 'Ward, Phil', :author => author
          reference = FactoryGirl.create :reference, :author_names => [bad]
          AuthorName.correct 'Ward, Phil', 'Ward, P. S.', false
          expect(AuthorName.find_by_name('Ward, Phil')).to be_nil
          expect(AuthorName.find_by_name('Ward, P. S.').author).to eq(author)
          expect(AuthorName.count).to eq(1)
          expect(Author.count).to eq(1)
        end
      end
    end
  end

  describe "finding preposition synonyms" do
    ['Le', 'La', 'De'].each do |preposition|
      it "should find names that differ only in having a space after the initial #{preposition}" do
        no_space = FactoryGirl.create :author_name, :name => "#{preposition}farge, M."
        with_space = FactoryGirl.create :author_name, :name => "#{preposition} Farge, M."
        FactoryGirl.create :author_name, :name => "#{preposition}me, M."
        expect(AuthorName.find_preposition_synonyms).to eq([[with_space, no_space]])
      end
    end
    it "should find names that differ only in having a preposition in the back instead of the front" do
      in_front = FactoryGirl.create :author_name, :name => "La Farge, M."
      in_back = FactoryGirl.create :author_name, :name => "Farge, M., La"
      FactoryGirl.create :author_name, :name => "me, M., La"
      expect(AuthorName.find_preposition_synonyms).to eq([[in_front, in_back]])
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        author_name = FactoryGirl.create :author_name
        expect(author_name.versions.last.event).to eq('create')
      end
    end
  end

end
