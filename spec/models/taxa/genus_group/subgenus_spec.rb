require 'rails_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }

  describe 'relations' do
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
  end
end
