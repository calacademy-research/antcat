require 'spec_helper'

describe CollectiveGroupName do
  specify { expect(described_class.new).to be_a Name }
end
