require 'spec_helper'

describe Status do
  describe "#to_s" do
    it "returns the singular and the plural for a status" do
      expect(described_class['synonym'].to_s).to eq 'synonym'
      expect(described_class['synonym'].to_s(:plural)).to eq 'synonyms'
    end
  end

  # Select box options
  describe ".options_for_select" do
    it "includes the option 'valid'" do
      expect(described_class.options_for_select.map(&:first).include?('valid')).to be_truthy
    end

    it "doesn't include the option 'nonsense'" do
      expect(described_class.options_for_select.map(&:first).include?('nonsense')).to be_falsey
    end
  end
end
