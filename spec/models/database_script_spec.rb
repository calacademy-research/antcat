# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScript do
  describe ".new_from_basename" do
    it "returns a database script" do
      expect(described_class.new_from_basename("ExtantTaxaInFossilGenera")).
        to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end
  end

  describe ".safe_new_from_basename" do
    it "returns a database script" do
      expect(described_class.safe_new_from_basename("ExtantTaxaInFossilGenera")).
        to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end

    context 'when database script does not exists' do
      it 'returns an "unfound database script"' do
        expect(described_class.safe_new_from_basename("BestPizza")).to be_a DatabaseScripts::UnfoundDatabaseScript
      end
    end
  end

  describe ".with_tag" do
    it "returns database scripts with at least one tag matching the given tags" do
      results = described_class.with_tag(DatabaseScripts::Tagging::SLOW_RENDER_TAG)
      results_basenames = results.map(&:basename)

      expect(results_basenames).to include DatabaseScripts::OrphanedProtonyms.new.basename
      expect(results_basenames).not_to include DatabaseScripts::ExtantTaxaInFossilGenera.new.basename
    end
  end

  describe '.record_in_results?' do
    context "when taxon is in the script's results" do
      subject(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera }

      let!(:extant_species) { create :species }

      specify do
        expect { extant_species.genus.protonym.update!(fossil: true) }.
          to change { database_script.record_in_results?(extant_species) }.
          from(false).to(true)
      end
    end
  end

  describe "#section" do
    describe 'section validation' do
      described_class.all.each do |database_script|
        it "#{database_script.basename} has a known section" do
          expect(database_script.section.in?(DatabaseScripts::Tagging::SECTIONS)).to eq true
        end
      end
    end
  end

  describe "#tags" do
    describe 'tags validation' do
      described_class.all.each do |database_script|
        it "#{database_script.basename} has only known tags" do
          expect(database_script.tags - DatabaseScripts::Tagging::TAGS).to eq []
        end
      end
    end
  end

  describe '#statistics' do
    subject(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera.new }

    context 'when script has no custom statistics' do
      it 'returns default statistics' do
        expect(database_script.statistics).to eq "Results: 0"
      end
    end

    context 'when script has custom statistics' do
      before do
        def database_script.statistics
          'Custom results'
        end
      end

      it "returns the script's `#statistics`" do
        expect(database_script.statistics).to eq 'Custom results'
      end
    end
  end

  describe "#to_param" do
    subject(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera.new }

    it "returns the filename without extension" do
      expect(database_script.to_param).to eq "extant_taxa_in_fossil_genera"
    end
  end

  describe "#cached_results" do
    subject(:database_script) { DatabaseScripts::DatabaseTestScript.new }

    context 'when results is present' do
      before do
        def database_script.results
          Taxon.count
          'present'
        end
      end

      it "doesn't call `#result` more than once" do
        expect(Taxon).to receive(:count).once

        database_script.__send__ :cached_results
        results = database_script.__send__ :cached_results

        expect(results).to eq 'present'
      end
    end

    context 'when results is `nil`' do
      before do
        def database_script.results
          Taxon.count
          nil
        end
      end

      it "doesn't call `#result` more than once" do
        expect(Taxon).to receive(:count).once

        database_script.__send__ :cached_results
        results = database_script.__send__ :cached_results

        expect(results).to eq nil
      end
    end

    described_class.all.each do |database_script|
      it "#{database_script.basename} calls `#results` only once" do
        if database_script.respond_to? :results
          expect(database_script).to receive(:results).at_most(:once).and_call_original
        end
        DatabaseScripts::Render.new(database_script).call
      end
    end
  end
end
