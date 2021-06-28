# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::JournalsQuery do
  describe "#call" do
    it "fuzzy matches journal names" do
      abp = create :journal, name: 'American Bibliographic Proceedings'
      create :journal, name: 'Playboy'
      expect(described_class['ABP']).to eq [abp]
    end

    it "requires matching the first letter" do
      create :journal, name: 'ABC'
      expect(described_class['BC']).to eq []
    end

    describe 'matching diacritics' do
      let!(:accented) { create :journal, name: 'Va' }
      let!(:unaccented) { create :journal, name: 'Vál' }

      specify do
        expect(described_class['va']).to match_array [accented, unaccented]
        expect(described_class['vá']).to match_array [accented, unaccented]
      end
    end

    it "returns results in order of most used" do
      most_used = create :journal
      never_used = create :journal
      rarely_used = create :journal

      2.times { create :article_reference, journal: rarely_used }
      3.times { create :article_reference, journal: most_used }

      expect(described_class['']).to eq [most_used, rarely_used, never_used]
    end
  end
end
