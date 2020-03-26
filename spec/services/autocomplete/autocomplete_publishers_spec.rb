# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::AutocompletePublishers do
  describe "#call" do
    let!(:publisher) { create :publisher, name: 'Wiley', place: 'Chicago' }

    it "fuzzy matches name/place combinations" do
      create :publisher, name: 'Wiley', place: 'Toronto'
      expect(described_class['chw']).to eq [publisher]
    end
  end
end
