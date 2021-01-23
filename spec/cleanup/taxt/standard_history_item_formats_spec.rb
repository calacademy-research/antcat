# frozen_string_literal: true

require 'rails_helper'

describe Taxt::StandardHistoryItemFormats do
  subject(:service) { described_class.new(taxt) }

  describe '#standard?' do
    context 'with blank item' do
      let(:taxt) { '' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context 'with nil item' do
      let(:taxt) { nil }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context 'with non-standard item' do
      let(:taxt) { 'pizza' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context "with form descriptions item" do
      context 'with known forms' do
        let(:taxt) { "{#{Taxt::REF_TAG} 1}: 2 (w.q.m.)." }

        specify do
          expect(service.standard?).to eq true
          expect(service.identified_type).to eq History::Definitions::FORM_DESCRIPTIONS
        end
      end

      context 'with unknown forms' do
        let(:taxt) { "{#{Taxt::REF_TAG} 1}: 2 (z.q.m.)." }

        specify do
          expect(service.standard?).to eq false
          expect(service.identified_type).to eq History::Definitions::TAXT
        end
      end
    end

    context "with 'Lectotype designation' item" do
      let(:taxt) { "Lectotype designation: {#{Taxt::REF_TAG} 1}: 23" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Neotype designation' item" do
      let(:taxt) { "Neotype designation: {#{Taxt::REF_TAG} 1}: 23" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Junior synonym of' item" do
      let(:taxt) { "Junior synonym of {#{Taxt::PROTT_TAG} 1}: {#{Taxt::REF_TAG} 2}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::JUNIOR_SYNONYM_OF
      end
    end

    context "with 'Senior synonym of' item" do
      let(:taxt) { "Senior synonym of {#{Taxt::PROTT_TAG} 1}: {#{Taxt::REF_TAG} 2}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::SENIOR_SYNONYM_OF
      end
    end

    context "with 'Material referred to' item with source" do
      let(:taxt) do
        "Material referred to {#{Taxt::TAX_TAG} 1} by {#{Taxt::REF_TAG} 125536}: 135"
      end

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::MATERIAL_REFERRED_TO_BY
      end
    end

    context "with 'Unavailable name' + 'material referred to' item with source" do
      let(:taxt) do
        "Unavailable name; material referred to {#{Taxt::TAX_TAG} 1} by {#{Taxt::REF_TAG} 125536}: 135"
      end

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY
      end
    end

    context "with 'Declared as unavailable (infrasubspecific) name' item" do
      let(:taxt) do
        "Declared as unavailable (infrasubspecific) name: {#{Taxt::REF_TAG} 2}: 3."
      end

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      end
    end

    context "with 'First available use of unavailable (infrasubspecific) name' item" do
      let(:taxt) { "[First available use of {#{Taxt::TAXAC_TAG} 1}; unavailable (infrasubspecific) name.]" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      end
    end

    context "with 'First available use of unavailable (infrasubspecific) name' item with source" do
      let(:taxt) do
        "[First available use of {#{Taxt::TAXAC_TAG} 1}; unavailable (infrasubspecific) name ({#{Taxt::REF_TAG} 2}: 3).]"
      end

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME_WITH_SOURCE
      end
    end
  end
end
