require 'rails_helper'

describe Autocomplete::AutocompletePublishers do
  describe "#call" do
    it "fuzzy matches name/place_name combinations" do
      create :publisher, name: 'Wiley', place_name: 'Chicago'
      create :publisher, name: 'Wiley', place_name: 'Toronto'
      expect(described_class['chw']).to eq ['Chicago: Wiley']
    end
  end
end
