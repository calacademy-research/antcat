# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::PublishersQuery do
  describe "#call" do
    let!(:publisher) { create :publisher, name: 'Libros', place: 'Rome' }

    it "fuzzy matches name/place combinations" do
      create :publisher # Non-match.

      expect(described_class['rml']).to eq [publisher]
      expect(described_class['libro']).to eq [publisher]
      expect(described_class['rom']).to eq [publisher]
    end
  end
end
