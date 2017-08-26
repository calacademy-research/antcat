require 'spec_helper'

describe Exporters::AdvancedSearchExporter do
  subject(:exporter) { described_class.new }

  describe "#export" do
    before do
      5.times { create_subfamily }
    end

    it "formats the taxa passed in" do
      expect(exporter.export(Subfamily.all).lines.size).to eq 15
    end
  end
end
