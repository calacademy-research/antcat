require 'spec_helper'

describe Place do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
end
