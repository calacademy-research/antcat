require 'spec_helper'

describe Role do
  it "validates `#name`" do
    expect(described_class.new).to_not be_valid
    expect(described_class.new(name: :jasdhkads)).to_not be_valid
    expect(described_class.new(name: :editor)).to be_valid
  end
end
