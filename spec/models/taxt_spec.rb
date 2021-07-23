# frozen_string_literal: true

require 'rails_helper'

describe Taxt do
  describe '.extract_ids_from_taxon_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("{taxa 123}")).to eq []
        expect(described_class.extract_ids_from_taxon_tags(Taxt.tax('123d'))).to eq []

        expect(described_class.extract_ids_from_taxon_tags(Taxt.pro(123))).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags(Taxt.tax('123'))).to eq [123]

        expect(described_class.extract_ids_from_taxon_tags("pizza #{Taxt.tax(123)} pizza")).to eq [123]
        expect(described_class.extract_ids_from_taxon_tags("pizza #{Taxt.taxac(123)} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        results = described_class.extract_ids_from_taxon_tags("pizza #{Taxt.taxac(1)} #{Taxt.tax(2)} #{Taxt.ref(3)}")
        expect(results).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_protonym_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("{prot 123}")).to eq []
        expect(described_class.extract_ids_from_protonym_tags(Taxt.tax('123d'))).to eq []

        expect(described_class.extract_ids_from_protonym_tags(Taxt.tax(123))).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags(Taxt.pro(123))).to eq [123]

        expect(described_class.extract_ids_from_protonym_tags("pizza #{Taxt.pro(123)} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza #{Taxt.prott(123)} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza #{Taxt.proac(123)} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza #{Taxt.prottac(123)} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        results = described_class.extract_ids_from_protonym_tags("pizza #{Taxt.pro(1)} #{Taxt.prott(2)} #{Taxt.ref(3)}")
        expect(results).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_reference_tags' do
    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_reference_tags(Taxt.ref(123))).to eq [123]
      end
    end
  end
end
