# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScript do
  describe ".new_from_filename" do
    it "returns a database script" do
      expect(described_class.new_from_filename("ExtantTaxaInFossilGenera")).
        to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end
  end

  describe ".safe_new_from_filename" do
    it "returns a database script" do
      expect(described_class.safe_new_from_filename("ExtantTaxaInFossilGenera")).
        to be_a DatabaseScripts::ExtantTaxaInFossilGenera
    end

    context 'when database script does not exists' do
      it 'returns an "unfound database script"' do
        expect(described_class.safe_new_from_filename("BestPizza")).to be_a DatabaseScripts::UnfoundDatabaseScript
      end
    end
  end

  describe '.record_in_results?' do
    context "when taxon is in the script's results" do
      subject(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera }

      let!(:extant_species) { create :species }

      specify do
        expect { extant_species.genus.update!(fossil: true) }.
          to change { database_script.record_in_results?(extant_species) }.
          from(false).to(true)
      end
    end
  end

  describe "#section" do
    described_class.all.each do |database_script|
      it "#{database_script.filename_without_extension} has a known section" do
        expect(database_script.section.in?(DatabaseScripts::Tagging::SECTIONS)).to eq true
      end
    end
  end

  describe "#title" do
    it "fetches the title from the END data" do
      database_script = DatabaseScripts::FossilProtonymsWithNonFossilTaxa.new
      expect(database_script.title).to eq "Fossil protonyms with non-fossil taxa"
    end

    it "defaults to the humanized filename" do
      database_script = DatabaseScripts::OrphanedProtonyms.new
      expect(database_script.title).to eq "Orphaned protonyms"
    end

    context "when filename ends with '_id'" do
      subject(:database_script) { DatabaseScripts::TaxaWithSameName.new }

      it "keeps the '_id' part" do
        expect(database_script.title).to eq 'Taxa with same name'

        def database_script.filename_without_extension
          'taxa_with_same_name_id'
        end

        expect(database_script.title).to eq 'Taxa with same name id'
      end
    end
  end

  describe "#related_scripts" do
    subject(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera.new }

    it "returns related scripts excluding itself" do
      expect(database_script.related_scripts.size).to eq 1
      expect(database_script.related_scripts.first).to be_a DatabaseScripts::ValidTaxaWithNonValidParents
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
      it "#{database_script.filename_without_extension} calls `#results` only once" do
        if database_script.respond_to? :results
          expect(database_script).to receive(:results).at_most(:once).and_call_original
        end
        database_script.render
      end
    end
  end
end
