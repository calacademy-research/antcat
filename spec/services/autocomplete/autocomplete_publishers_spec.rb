require "spec_helper"

describe Autocomplete::AutocompletePublishers do
  describe "#call" do
    it "fuzzy matches name/place_name combinations" do
      Publisher.create! name: 'Wiley', place_name: 'Chicago'
      Publisher.create! name: 'Wiley', place_name: 'Toronto'
      expect(described_class['chw']).to eq ['Chicago: Wiley']
    end

    it "can find a match even if there's no `place_name`" do
      Publisher.create! name: 'Wiley'
      expect(described_class['w']).to eq ['Wiley']
    end
  end
end
