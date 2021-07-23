# frozen_string_literal: true

require 'rails_helper'

describe Taxt do
  describe '.extract_ids_from_taxon_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("{taxa 123}")).to eq []
        expect(described_class.extract_ids_from_taxon_tags("{#{Taxt::TAX_TAG} 123d}")).to eq []

        expect(described_class.extract_ids_from_taxon_tags("{#{Taxt::PRO_TAG} 123}")).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("{#{Taxt::TAX_TAG} 123}")).to eq [123]

        expect(described_class.extract_ids_from_taxon_tags("pizza {#{Taxt::TAX_TAG} 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_taxon_tags("pizza {#{Taxt::TAXAC_TAG} 123} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        results = described_class.extract_ids_from_taxon_tags("pizza {#{Taxt::TAXAC_TAG} 1} {#{Taxt::TAX_TAG} 2} {#{Taxt::REF_TAG} 3}")
        expect(results).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_protonym_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("{prot 123}")).to eq []
        expect(described_class.extract_ids_from_protonym_tags("{#{Taxt::PRO_TAG} 123d}")).to eq []

        expect(described_class.extract_ids_from_protonym_tags("{#{Taxt::TAX_TAG} 123}")).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("{#{Taxt::PRO_TAG} 123}")).to eq [123]

        expect(described_class.extract_ids_from_protonym_tags("pizza {#{Taxt::PRO_TAG} 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {#{Taxt::PROTT_TAG} 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {#{Taxt::PROAC_TAG} 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {#{Taxt::PROTTAC_TAG} 123} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        results = described_class.extract_ids_from_protonym_tags("pizza {#{Taxt::PRO_TAG} 1} {#{Taxt::PROTT_TAG} 2} {#{Taxt::REF_TAG} 3}")
        expect(results).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_reference_tags' do
    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_reference_tags("{#{Taxt::REF_TAG} 123}")).to eq [123]
      end
    end
  end
end
