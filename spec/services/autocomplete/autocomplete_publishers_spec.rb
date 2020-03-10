require 'rails_helper'

describe Autocomplete::AutocompletePublishers do
  describe "#call" do
    let!(:publisher) { create :publisher, name: 'Wiley', place_name: 'Chicago' }

    it "fuzzy matches name/place_name combinations" do
      create :publisher, name: 'Wiley', place_name: 'Toronto'
      expect(described_class['chw']).to eq [publisher]
    end
  end
end
