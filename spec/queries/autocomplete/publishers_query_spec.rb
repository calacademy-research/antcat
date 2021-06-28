# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::PublishersQuery do
  describe "#call" do
    describe 'fuzzy matching' do
      let!(:publisher) { create :publisher, name: 'Libros', place: 'Rome' }

      it "fuzzy matches name/place combinations" do
        create :publisher # Non-match.

        expect(described_class['rml']).to eq [publisher]
        expect(described_class['libro']).to eq [publisher]
        expect(described_class['rom']).to eq [publisher]
      end
    end

    describe 'matching diacritics' do
      let!(:accented) { create :publisher, name: 'Vá 1' }
      let!(:unaccented) { create :publisher, name: 'Va 2' }

      specify do
        expect(described_class['va']).to match_array [accented, unaccented]
        expect(described_class['vá']).to match_array [accented, unaccented]
      end
    end
  end
end
