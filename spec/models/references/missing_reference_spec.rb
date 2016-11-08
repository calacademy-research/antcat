require 'spec_helper'

describe MissingReference do
  describe "Optional year" do
    it "permits a missing year (unlike other references)" do
      reference = MissingReference.new title: 'missing', citation: 'Bolton'
      expect(reference).to be_valid
    end
  end

  describe "#keey" do
    it "has its own kind of decorator" do
      reference = build_stubbed :missing_reference
      expect(reference.decorate).to be_kind_of MissingReferenceDecorator
    end
  end
end
