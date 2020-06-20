# frozen_string_literal: true

require 'rails_helper'

describe TypeName do
  it { is_expected.to be_versioned }

  describe 'validations' do
    describe '#fixation_method' do
      subject(:type_name) { build_stubbed :type_name }

      it do
        expect(type_name).to validate_inclusion_of(:fixation_method).
          in_array(described_class::FIXATION_METHODS).allow_nil
      end
    end

    context "when `fixation_method` is `BY_SUBSEQUENT_DESIGNATION_OF`" do
      let!(:type_name) { create :type_name, :by_monotypy }

      it 'requires a reference and pages' do
        expect { type_name.fixation_method = described_class::BY_SUBSEQUENT_DESIGNATION_OF }.
          to change { type_name.valid? }.to(false)

        expect(type_name.errors[:reference]).to eq ["must be set for 'by subsequent designation of'"]
        expect(type_name.errors[:pages]).to eq ["must be set for 'by subsequent designation of'"]
      end
    end

    context "when `fixation_method` is not `BY_SUBSEQUENT_DESIGNATION_OF`" do
      let!(:type_name) { create :type_name, :by_subsequent_designation_of }

      it 'cannot have a reference or pages' do
        expect { type_name.fixation_method = described_class::BY_MONOTYPY }.
          to change { type_name.valid? }.to(false)

        expect(type_name.errors[:reference]).to eq ["can only be set for 'by subsequent designation of'"]
        expect(type_name.errors[:pages]).to eq ["can only be set for 'by subsequent designation of'"]
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:fixation_method, :pages) }
  end
end
