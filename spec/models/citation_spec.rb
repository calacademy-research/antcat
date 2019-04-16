require 'spec_helper'

describe Citation do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :reference }
  it { is_expected.to validate_presence_of :pages }
end
