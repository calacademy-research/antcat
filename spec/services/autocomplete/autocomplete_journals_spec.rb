require "spec_helper"

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
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        create :journal, name: name
      end
      2.times { create :article_reference, journal: Journal.find_by(name: 'Rarely Used') }
      3.times { create :article_reference, journal: Journal.find_by(name: 'Occasionally Used') }
      4.times { create :article_reference, journal: Journal.find_by(name: 'Most Used') }
      0.times { create :article_reference, journal: Journal.find_by(name: 'Never Used') }

      expect(described_class[]).to eq ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end
end
