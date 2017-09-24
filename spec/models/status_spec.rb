require 'spec_helper'

describe Status do
  describe "#to_s" do
    it "returns the singular and the plural for a status" do
      expect(described_class['synonym'].to_s).to eq 'synonym'
      expect(described_class['synonym'].to_s(:plural)).to eq 'synonyms'
    end
  end

  describe ".options_for_select" do
    specify do
      expect(described_class.options_for_select.map(&:first)).to eq [
        "valid", "synonym", "homonym", "unidentifiable", "unavailable",
        "excluded from Formicidae", "original combination", "collective group name",
        "obsolete combination", "unavailable misspelling", "nonconforming synonym",
        "unavailable uncategorized"
      ]
    end
  end
end
