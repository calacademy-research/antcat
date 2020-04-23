# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Statistics::FormatStatistics do
  describe '#call' do
    context 'when statistics is blank' do
      specify do
        expect(described_class[nil]).to eq nil
        expect(described_class[{}]).to eq nil
      end
    end

    context "when statistics contains both extant and fossil statistics" do
      let(:statistics) do
        {
          extant: {
            subfamilies: { 'valid' => 1 },
            genera: { 'valid' => 2, 'synonym' => 1, 'homonym' => 2 },
            species: { 'valid' => 1 }
          },
          fossil: {
            subfamilies: { 'valid' => 2 }
          }
        }
      end

      specify do
        expect(described_class[statistics]).
          to eq '<p>Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>' \
          '<p>Fossil: 2 valid subfamilies</p>'
      end
    end

    context "when statistics contains only fossil statistics" do
      specify { expect(described_class[fossil: { subfamilies: { 'valid' => 2 } }]).to eq '<p>Fossil: 2 valid subfamilies</p>' }
    end

    describe 'pluralization' do
      context 'when statistics contains a single taxon of a rank' do
        it "does not pluralize the rank" do
          expect(described_class[extant: { subfamilies: { 'valid' => 1 } }]).to eq '<p>Extant: 1 valid subfamily</p>'
          expect(described_class[extant: { tribes: { 'valid' => 1 } }]).to eq '<p>Extant: 1 valid tribe</p>'
          expect(described_class[extant: { genera: { 'valid' => 1 } }]).to eq '<p>Extant: 1 valid genus</p>'
          expect(described_class[extant: { subgenera: { 'valid' => 1 } }]).to eq '<p>Extant: 1 valid subgenus</p>'
        end
      end

      context 'when statistics contains statuses that should not be pluralized' do
        it "doesn't pluralize the statuses" do
          expect(described_class[extant: { species: { 'valid' => 2 } }]).to eq '<p>Extant: 2 valid species</p>'
          expect(described_class[extant: { species: { 'synonym' => 2 } }]).to eq '<p>Extant: 0 valid species (2 synonyms)</p>'
          expect(described_class[extant: { species: { 'unavailable' => 2 } }]).to eq '<p>Extant: 0 valid species (2 unavailable)</p>'
          expect(described_class[extant: { species: { 'excluded from Formicidae' => 2 } }]).
            to eq '<p>Extant: 0 valid species (2 excluded from Formicidae)</p>'
        end
      end
    end

    context "when statistics for a rank contains only invalid statistics" do
      let(:statistics) do
        {
          extant: { subspecies: { 'synonym' => 1 } }
        }
      end

      it "appends '0 valid' before the invalid statistics" do
        expect(described_class[statistics]).to eq '<p>Extant: 0 valid subspecies (1 synonym)</p>'
      end
    end
  end
end
