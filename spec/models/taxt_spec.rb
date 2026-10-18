# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable-next RSpec/DescribedClass
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

  describe '.replace_hidden_notes' do
    it 'yields the content of each note, including nested tags, and whether it was closed' do
      taxt = "Lasius{#{Taxt::HIDDENNOTE_TAG} x {ref 1}: 3 y} z {#{Taxt::HIDDENNOTE_TAG} open"
      expect(described_class.replace_hidden_notes(taxt) { |content, closed| "[#{content}|#{closed}]" }).
        to eq "Lasius[x {ref 1}: 3 y|true] z [open|false]"
    end
  end

  describe '.remove_hidden_notes' do
    it 'removes hidden notes and the space before them' do
      expect(described_class.remove_hidden_notes("Lasius {#{Taxt::HIDDENNOTE_TAG} check} and {tax 1}")).
        to eq "Lasius and {tax 1}"
      expect(described_class.remove_hidden_notes("{#{Taxt::HIDDENNOTE_TAG} a}{#{Taxt::HIDDENNOTE_TAG} b}x")).to eq "x"
    end

    it 'removes notes that contain other tags or braces, up to the matching closing brace' do
      expect(described_class.remove_hidden_notes("Foo. {#{Taxt::HIDDENNOTE_TAG} check {ref 123}: 45, wrong here} Bar.")).
        to eq "Foo. Bar."
      expect(described_class.remove_hidden_notes("A {#{Taxt::HIDDENNOTE_TAG} x {a {b}} {#{Taxt::HIDDENNOTE_TAG} y} z} B")).
        to eq "A B"
    end

    it 'removes a note without a closing brace up to the end of the text' do
      expect(described_class.remove_hidden_notes("A {tax 1} {#{Taxt::HIDDENNOTE_TAG} check {ref 1} and more")).
        to eq "A {tax 1}"
    end

    it 'runs in linear time on many unclosed notes' do
      taxt = ("{#{Taxt::HIDDENNOTE_TAG} " * 5_000) + ("x" * 50_000)
      expect { Timeout.timeout(2) { described_class.remove_hidden_notes(taxt) } }.not_to raise_error
    end

    it 'returns other values as they are' do
      expect(described_class.remove_hidden_notes("Lasius")).to eq "Lasius"
      expect(described_class.remove_hidden_notes(nil)).to eq nil
      expect(described_class.remove_hidden_notes(1)).to eq 1
    end
  end
end
