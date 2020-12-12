# frozen_string_literal: true

require 'rails_helper'

describe Taxt::StandardHistoryItemFormats do
  subject(:service) { described_class.new(taxt) }

  describe '#standard?' do
    context 'with blank item' do
      let(:taxt) { '' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq described_class::TAXT
      end
    end

    context 'with nil item' do
      let(:taxt) { nil }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq described_class::TAXT
      end
    end

    context 'with non-standard item' do
      let(:taxt) { 'pizza' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq described_class::TAXT
      end
    end

    context "with form descriptions item" do
      context 'with known forms' do
        let(:taxt) { '{ref 1}: 2 (w.q.m.).' }

        specify do
          expect(service.standard?).to eq true
          expect(service.identified_type).to eq HistoryItem::FORM_DESCRIPTIONS
        end
      end

      context 'with unknown forms' do
        let(:taxt) { '{ref 1}: 2 (z.q.m.).' }

        specify do
          expect(service.standard?).to eq false
          expect(service.identified_type).to eq described_class::TAXT
        end
      end
    end

    context "with 'Lectotype designation' item" do
      let(:taxt) { 'Lectotype designation: {ref 1}: 23' }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq HistoryItem::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Neotype designation' item" do
      let(:taxt) { 'Neotype designation: {ref 1}: 23' }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq HistoryItem::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Junior synonym of' item" do
      let(:taxt) { 'Junior synonym of {prott 1}: {ref 2}: 3.' }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq HistoryItem::JUNIOR_SYNONYM_OF
      end
    end

    context "with 'Senior synonym of' item" do
      let(:taxt) { 'Senior synonym of {prott 1}: {ref 2}: 3.' }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq HistoryItem::SENIOR_SYNONYM_OF
      end
    end
  end
end
