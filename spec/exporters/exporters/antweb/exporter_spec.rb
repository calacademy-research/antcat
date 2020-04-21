# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::Exporter do
  describe "#call" do
    let(:filename) { "antweb_export_test" }
    let(:file) { instance_double('File') }

    before do
      allow($stdout).to receive(:write) # Suppress progress output.
    end

    it "writes data to the specified file" do
      expect(File).to receive(:open).with(filename, "w").and_yield(file)
      expect(file).to receive(:puts).with(anything)
      described_class[filename]
    end

    it "calls `Exporters::Antweb::ExportTaxon`" do
      allow(File).to receive(:open).with(filename, "w").and_yield(file)
      allow(file).to receive(:puts).with(anything)

      taxon = create :family
      expect(Exporters::Antweb::ExportTaxon).to receive(:new).with(taxon).and_call_original
      described_class[filename]
    end
  end
end
