require 'spec_helper'

describe Institution do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :abbreviation }

  describe "uniqueness validation" do
    subject { create :institution }

    it { is_expected.to validate_uniqueness_of :abbreviation }
  end
end
