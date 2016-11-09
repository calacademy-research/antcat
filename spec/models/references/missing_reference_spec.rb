require 'spec_helper'

describe MissingReference do
  it { should allow_value(nil).for :year }

  describe "#keey" do
    it "has its own kind of decorator" do
      reference = build_stubbed :missing_reference
      expect(reference.decorate).to be_kind_of MissingReferenceDecorator
    end
  end
end
