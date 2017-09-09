require 'spec_helper'

describe AuthorName do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :author }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many :references }

  let(:author) { Author.create! }

  it "can't be a duplicate" do
    author_name = create :author_name, name: 'Bolton'
    author_name.author = create :author
    author_name.save!

    author_name = build :author_name, name: 'Bolton'
    expect(author_name).not_to be_valid
  end

  describe "#import" do
    it "creates and returns the authors" do
      results = described_class.import ['Fisher, B.L.', 'Wheeler, W.M.']
      expect(results.map(&:name)).to match_array ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "reuses existing authors" do
      described_class.import ['Fisher, B.L.', 'Wheeler, W.M.']
      described_class.import ['Fisher, B.L.', 'Wheeler, W.M.']
      expect(described_class.count).to eq 2
    end

    it "is case sensitive" do
      described_class.import ['Mackay, W. M.', 'MacKay, W. M.']
      expect(described_class.count).to eq 2
    end
  end

  describe "editing" do
    it "updates associated references when the name is changed" do
      author_name = create :author_name, name: 'Ward'
      reference = create :reference, author_names: [author_name]
      author_name.update_attribute :name, 'Fisher'
      expect(Reference.find(reference.id).author_names_string).to eq 'Fisher'
    end
  end

  describe "#import_author_names_string" do
    it "finds or creates authors with names in the string" do
      described_class.create! name: 'Bolton, B.', author: author
      author_data = described_class.import_author_names_string 'Ward, P.S.; Bolton, B.'
      expect(author_data[:author_names].first.name).to eq 'Ward, P.S.'
      expect(author_data[:author_names].second.name).to eq 'Bolton, B.'
      expect(author_data[:author_names_suffix]).to be_nil
      expect(described_class.count).to eq 2
    end

    it "returns the authors suffix" do
      author_data = described_class.import_author_names_string 'Ward, P.S.; Bolton, B. (eds.)'
      expect(author_data[:author_names].first.name).to eq 'Ward, P.S.'
      expect(author_data[:author_names].second.name).to eq 'Bolton, B.'
      expect(author_data[:author_names_suffix]).to eq ' (eds.)'
    end

    it "handles 'the Andres'" do
      author_data = described_class.import_author_names_string 'Andre, Edm.; Andre, Ern.'
      expect(author_data[:author_names].first.name).to eq 'Andre, Edm.'
      expect(author_data[:author_names].second.name).to eq 'Andre, Ern.'
    end

    it "handles invalid input" do
      author_data = described_class.import_author_names_string ' ; '
      expect(author_data[:author_names]).to eq []
      expect(author_data[:author_names_suffix]).to be_nil
    end

   it "handles a semicolon followed by a space at the end" do
     author_data = described_class.import_author_names_string 'Ward, P. S.; '
     expect(author_data[:author_names].size).to eq 1
     expect(author_data[:author_names].first.name).to eq 'Ward, P. S.'
     expect(author_data[:author_names_suffix]).to be_nil
   end
  end

  describe "#last_name and #first_name_and_initials" do
    it "simply returns the name if there's only one word" do
      author_name = described_class.new name: 'Bolton'
      expect(author_name.last_name).to eq 'Bolton'
      expect(author_name.first_name_and_initials).to be_nil
    end

    it "separates the words if there are multiple" do
      author_name = described_class.new name: 'Bolton, B.L.'
      expect(author_name.last_name).to eq 'Bolton'
      expect(author_name.first_name_and_initials).to eq 'B.L.'
    end

    it "uses all words if there is no comma" do
      author_name = described_class.new name: 'Royal Academy'
      expect(author_name.last_name).to eq 'Royal Academy'
      expect(author_name.first_name_and_initials).to be_nil
    end

    it "uses all words before the comma if there are multiple" do
      author_name = described_class.new name: 'Baroni Urbani, C.'
      expect(author_name.last_name).to eq 'Baroni Urbani'
      expect(author_name.first_name_and_initials).to eq 'C.'
    end
  end
end
