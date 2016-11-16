require 'spec_helper'

describe MissingReference do
  it { should allow_value(nil).for :year }

  describe "#keey" do
    it "is the citation" do
      reference = build_stubbed :missing_reference, citation: "citation"
      expect(reference.keey).to eq "citation"
    end
  end
end
