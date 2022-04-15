# frozen_string_literal: true

require 'rails_helper'

describe Institution do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :abbreviation }
    it { is_expected.to validate_length_of(:name).is_at_most(described_class::NAME_MAX_LENGTH) }
    it { is_expected.to validate_length_of(:abbreviation).is_at_most(described_class::ABBREVIATION_MAX_LENGTH) }

    describe '#grscicoll_identifier' do
      let(:valid_v4_uuid) { 'e6e9d21b-faf8-4698-95e6-bacc55860a95' }

      it { is_expected.to allow_value(nil).for(:grscicoll_identifier) }

      it 'only allows valid identifiers' do
        is_expected.to allow_value("collection/#{valid_v4_uuid}").for(:grscicoll_identifier)
        is_expected.to allow_value("institution/#{valid_v4_uuid}").for(:grscicoll_identifier)
      end

      it 'disallows unknown prefixes' do
        is_expected.not_to allow_value("pizza/#{valid_v4_uuid}").for(:grscicoll_identifier)
      end

      it 'disallows invalid v4 UUIDs' do
        is_expected.not_to allow_value("institution/zzzzzzzz-faf8-4698-95e6-bacc55860a95").for(:grscicoll_identifier)
        is_expected.not_to allow_value("institution/00000000-0000-0000-0000-000000000000").for(:grscicoll_identifier)
      end
    end

    describe "uniqueness validation" do
      subject { create :institution }

      it { is_expected.to validate_uniqueness_of(:abbreviation).ignoring_case_sensitivity }
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:grscicoll_identifier) }
  end
end
