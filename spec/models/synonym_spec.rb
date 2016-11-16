require 'spec_helper'

describe Synonym do
  it { should be_versioned }
  it { should validate_presence_of :junior_synonym }
end
