require 'spec_helper'

describe TribeName do
  let(:name) { TribeName.new name: 'Attini', name_html: "Attini" }

  describe "#to_s" do
    it "works" do
      expect(name.to_s).to eq 'Attini'
    end
  end

  describe "#to_s" do
    it "works" do
      expect(name.to_html).to eq 'Attini'
    end
  end
end
