require 'rails_helper'

describe Autocomplete::AutocompleteAuthorNames do
  describe "#call" do
    it "matches by prefix" do
      bolton = create :author_name, name: 'Bolton'
      create :author_name, name: 'Fisher'

      expect(described_class['bol']).to eq [bolton]
    end

    it "matches substrings" do
      bolton = create :author_name, name: 'Bolton'
      create :author_name, name: 'Fisher'

      expect(described_class['ol']).to eq [bolton]
    end

    it "returns authors in order of most recently created" do
      recent = create :author_name
      old = create :author_name
      most_recent = create :author_name

      reference = create :reference, author_names: [most_recent]
      create :reference_author_name, created_at: 5.seconds.ago, author_name: recent, reference: reference
      create :reference_author_name, created_at: 10.seconds.ago, author_name: old, reference: reference

      expect(described_class[]).to eq [most_recent, recent, old]
    end
  end
end
