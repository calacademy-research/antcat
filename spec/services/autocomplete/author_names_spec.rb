require "spec_helper"

describe Autocomplete::AuthorNames do
  let(:author) { Author.create! }

  describe "#call" do
    it "matches by prefix" do
      bolton = AuthorName.create! name: 'Bolton', author: author
      AuthorName.create! name: 'Fisher', author: author

      expect(described_class['bol']).to eq [bolton.name]
    end

    it "matches substrings" do
      bolton = AuthorName.create! name: 'Bolton', author: author
      AuthorName.create! name: 'Fisher', author: author

      expect(described_class['ol']).to eq [bolton.name]
    end

    it "returns authors in order of most recently used" do
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        AuthorName.create! name: name, author: author
      end
      reference = create :reference, author_names: [AuthorName.find_by(name: 'Most Recent')]
      ReferenceAuthorName.create! created_at: Time.now - 5,
        author_name: AuthorName.find_by(name: 'Recent'),
        reference: reference
      ReferenceAuthorName.create! created_at: Time.now - 10,
        author_name: AuthorName.find_by(name: 'Old'),
        reference: reference

      expect(described_class[]).to eq ['Most Recent', 'Recent', 'Old', 'Never Used']
    end
  end
end
