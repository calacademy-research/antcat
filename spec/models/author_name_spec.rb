# coding: UTF-8
require 'spec_helper'

describe AuthorName do
  let(:author) { Author.create! }

  it "has many references" do
    author_name = AuthorName.create! :name => 'Fisher, B.L.', :author => author

    reference = FactoryGirl.create(:reference)
    author_name.references << reference

    expect(author_name.references.first).to eq(reference)
  end

  it "has an author" do
    AuthorName.create! :author => author, :name => 'Fisher, B.L.', :author => author
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
      AuthorName.create! :name => 'Bolton, B.', :author => author
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
      AuthorName.create! :name => 'Bolton', :author => author
      AuthorName.create! :name => 'Fisher', :author => author
      results = AuthorName.search('Bol')
      expect(results.count).to eq(1)
      expect(results.first).to eq('Bolton')
    end

    it "should find an internal string" do
      AuthorName.create! :name => 'Bolton', :author => author
      AuthorName.create! :name => 'Fisher', :author => author
      results = AuthorName.search('ol')
      expect(results.count).to eq(1)
      expect(results.first).to eq('Bolton')
    end

    it "should return authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        AuthorName.create! :name => name, :author => author
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

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        author_name = FactoryGirl.create :author_name
        expect(author_name.versions.last.event).to eq('create')
      end
    end
  end

end
