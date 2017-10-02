require 'spec_helper'

describe Synonym do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :junior_synonym }
  it { is_expected.to validate_presence_of :senior_synonym }
end
