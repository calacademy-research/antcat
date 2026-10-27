# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::Exporter do
  describe "#call" do
    let(:dir) { Dir.mktmpdir }
    let(:filename) { File.join(dir, "antweb_export_test") }

    before do
      allow($stdout).to receive(:write) # Suppress progress output.
    end

    after do
      FileUtils.remove_entry(dir)
    end

    it "writes the header and one row per taxon to the specified file" do
      taxon = create :family
      described_class[filename]

      lines = File.readlines(filename, chomp: true)
      expect(lines.first).to eq Exporters::Antweb::ExportTaxon::HEADER
      expect(lines.size).to eq 2
      expect(lines.second).to start_with "#{taxon.id}\t"
      expect(File.exist?("#{filename}.tmp")).to be false
    end

    it "calls `Exporters::Antweb::ExportTaxon`" do
      taxon = create :family
      expect(Exporters::Antweb::ExportTaxon).to receive(:new).with(taxon).and_call_original
      described_class[filename]
    end

    it "keeps the previous export when the export fails" do
      File.write(filename, "previous export\n")
      create :family
      allow(Exporters::Antweb::ExportTaxon).to receive(:new).and_raise(StandardError, "boom")
      allow($stdout).to receive(:puts)

      expect { described_class[filename] }.to raise_error(StandardError, "boom")
      expect(File.read(filename)).to eq "previous export\n"
    end
  end
end
