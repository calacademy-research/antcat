require 'rails_helper'

describe Journal do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'relations' do
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end
end
