require 'spec_helper'

describe Journal do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }

  describe 'relations' do
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end
end
