require 'spec_helper'

describe Exporters::AdvancedSearchExporter do
  describe "#call" do
    before { 5.times { create_subfamily } }

    it "formats the taxa passed in" do
      expect(described_class[Subfamily.all].lines.size).to eq 15
    end
  end
end
