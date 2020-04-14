# frozen_string_literal: true

require 'rails_helper'

describe Journal do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }

    describe "uniqueness validation" do
      subject { create :journal }

      it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end
end
