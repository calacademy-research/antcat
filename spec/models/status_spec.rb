require 'spec_helper'

describe Status do
  describe "#to_s" do
    it "returns the singular and the plural for a status" do
      expect(described_class['synonym'].to_s).to eq 'synonym'
      expect(described_class['synonym'].to_s(:plural)).to eq 'synonyms'
    end
  end
end
