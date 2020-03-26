# frozen_string_literal: true

require 'rails_helper'

describe Institution do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :abbreviation }
    it { is_expected.to validate_length_of(:name).is_at_most(described_class::NAME_MAX_LENGTH) }
    it { is_expected.to validate_length_of(:abbreviation).is_at_most(described_class::ABBREVIATION_MAX_LENGTH) }

    describe "uniqueness validation" do
      subject { create :institution }

      it { is_expected.to validate_uniqueness_of(:abbreviation).ignoring_case_sensitivity }
    end
  end
end
