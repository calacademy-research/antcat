require "spec_helper"

describe Autocomplete::AutocompleteAuthorNames do
  let(:author) { create :author }

  describe "#call" do
    it "matches by prefix" do
      bolton = create :author_name, name: 'Bolton', author: author
      create :author_name, name: 'Fisher', author: author

      expect(described_class['bol']).to eq [bolton]
    end

    it "matches substrings" do
      bolton = create :author_name, name: 'Bolton', author: author
      create :author_name, name: 'Fisher', author: author

      expect(described_class['ol']).to eq [bolton]
    end

    it "returns authors in order of most recently used" do
      never_used =  create :author_name, author: author
      recent =      create :author_name, author: author
      old =         create :author_name, author: author
      most_recent = create :author_name, author: author

      reference = create :reference, author_names: [most_recent]
      create :reference_author_name, created_at: 5.seconds.ago, author_name: recent, reference: reference
      create :reference_author_name, created_at: 10.seconds.ago, author_name: old, reference: reference

      expect(described_class[]).to eq [most_recent, recent, old, never_used]
    end
  end
end
