# frozen_string_literal: true

require 'rails_helper'

describe Taxt::StandardHistoryItemFormats do
  describe '.standard?' do
    context 'with blank item' do
      specify { expect(described_class.standard?('')).to eq false }
      specify { expect(described_class.standard?(nil)).to eq false }
    end

    context 'with non-standard item' do
      specify { expect(described_class.standard?('pizza')).to eq false }
    end

    context "with 'Lectotype designation' item" do
      specify do
        expect(described_class.standard?('Lectotype designation: {ref 1}: 23')).to eq true
      end
    end

    context "with 'Neotype designation' item" do
      specify do
        expect(described_class.standard?('Neotype designation: {ref 1}: 2.')).to eq true
      end
    end

    context "with 'Junior synonym of' item" do
      specify do
        expect(described_class.standard?('Junior synonym of {prott 1}: {ref 2}: 3.')).to eq true
      end
    end

    context "with 'Senior synonym of' item" do
      specify do
        expect(described_class.standard?('Senior synonym of {prott 1}: {ref 2}: 3.')).to eq true
      end
    end

    context "with form descriptions item" do
      specify do
        expect(described_class.standard?('{ref 1}: 2 (w.q.m.).')).to eq true
      end

      it 'fails items with unknown forms' do
        expect(described_class.standard?('{ref 1}: 2 (z.q.m.).')).to eq false
      end
    end
  end
end
