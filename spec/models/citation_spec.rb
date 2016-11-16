require 'spec_helper'

describe Citation do
  it { should be_versioned }
  it { should validate_presence_of :reference }
end
