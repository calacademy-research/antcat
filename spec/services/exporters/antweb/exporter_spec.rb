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

    describe "`AW_EXPORT_LIMIT`" do
      before do
        create :family
        create :subfamily
      end

      def exported_rows limit
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('AW_EXPORT_LIMIT').and_return(limit)
        described_class[filename]
        File.readlines(filename, chomp: true).size - 1
      end

      it "limits the export to that many taxa" do
        expect(exported_rows('1')).to eq 1
      end

      it "exports all taxa when blank or not a number" do
        all_rows = exported_rows(nil)
        expect(all_rows).to be > 1
        expect(exported_rows('')).to eq all_rows
        expect(exported_rows('all')).to eq all_rows
      end
    end
  end
end
