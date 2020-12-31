# frozen_string_literal: true

require 'rails_helper'

describe Taxt do
  describe '.to_ref_tag' do
    let(:reference) { create :any_reference }

    it 'generates a taxt tag for the reference or reference ID' do
      expect(described_class.to_ref_tag(reference)).to eq "{ref #{reference.id}}"
      expect(described_class.to_ref_tag(reference.id)).to eq "{ref #{reference.id}}"
    end
  end

  describe '.extract_ids_from_taxon_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("{taxa 123}")).to eq []
        expect(described_class.extract_ids_from_taxon_tags("{tax 123d}")).to eq []

        expect(described_class.extract_ids_from_taxon_tags("{pro 123}")).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("{tax 123}")).to eq [123]

        expect(described_class.extract_ids_from_taxon_tags("pizza {tax 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_taxon_tags("pizza {taxac 123} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        expect(described_class.extract_ids_from_taxon_tags("pizza {taxac 1} {tax 2} {ref 3}")).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_protonym_tags' do
    context 'without matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("{prot 123}")).to eq []
        expect(described_class.extract_ids_from_protonym_tags("{pro 123d}")).to eq []

        expect(described_class.extract_ids_from_protonym_tags("{tax 123}")).to eq []
      end
    end

    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("{pro 123}")).to eq [123]

        expect(described_class.extract_ids_from_protonym_tags("pizza {pro 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {prott 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {proac 123} pizza")).to eq [123]
        expect(described_class.extract_ids_from_protonym_tags("pizza {prottac 123} pizza")).to eq [123]
      end
    end

    context 'with mixed tags' do
      specify do
        expect(described_class.extract_ids_from_protonym_tags("pizza {pro 1} {prott 2} {ref 3}")).to eq [1, 2]
      end
    end
  end

  describe '.extract_ids_from_reference_tags' do
    context 'with matching tags' do
      specify do
        expect(described_class.extract_ids_from_reference_tags("{ref 123}")).to eq [123]
      end
    end
  end
end
