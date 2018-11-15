require 'spec_helper'

describe SubtribeName do
  specify { expect(described_class.new).to be_a Name }
end
