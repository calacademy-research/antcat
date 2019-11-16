require 'rails_helper'

describe Autocomplete::AutocompleteJournals do
  describe "#call" do
    it "fuzzy matches journal names" do
      create :journal, name: 'American Bibliographic Proceedings'
      create :journal, name: 'Playboy'
      expect(described_class['ABP']).to eq ['American Bibliographic Proceedings']
    end

    it "requires matching the first letter" do
      create :journal, name: 'ABC'
      expect(described_class['BC']).to eq []
    end

    it "returns results in order of most used" do
      most_used = create :journal
      never_used = create :journal
      rarely_used = create :journal

      2.times { create :article_reference, journal: rarely_used }
      3.times { create :article_reference, journal: most_used }

      expect(described_class['']).to eq [most_used.name, rarely_used.name, never_used.name]
    end
  end
end
