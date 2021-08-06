# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::AuthorNamesQuery do
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

    describe 'matching diacritics' do
      let!(:accented) { create :author_name, name: 'Vázquez' }
      let!(:unaccented) { create :author_name, name: 'Vazquez' }

      specify do
        expect(described_class['va']).to match_array [accented, unaccented]
        expect(described_class['vá']).to match_array [accented, unaccented]
      end
    end
  end
end
