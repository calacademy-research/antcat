require 'spec_helper'

describe Place do
  it { should be_versioned }
  it { should validate_presence_of :name }
end
