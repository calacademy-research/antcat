require 'spec_helper'

describe Protonym do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :authorship }

  describe 'relations' do
    it { is_expected.to belong_to(:authorship).dependent(:destroy) }
  end
end
