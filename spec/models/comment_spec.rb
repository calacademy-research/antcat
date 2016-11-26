require "spec_helper"

describe Comment do
  it { should be_versioned }
  it { should validate_presence_of :body }
  it { should validate_presence_of :user }
end
