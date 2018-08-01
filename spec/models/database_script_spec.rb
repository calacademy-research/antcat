require "spec_helper"

describe DatabaseScript do
  describe ".new_from_filename_without_extension" do
    it "initializes" do
      results = described_class.new_from_filename_without_extension "SubspeciesWithoutSpecies"
      expect(results).to be_a DatabaseScripts::SubspeciesWithoutSpecies
    end
  end

  describe "#cached_results" do
    let(:database_script) { DatabaseTestScript.new }

    it "doesn't call `#result` more than once" do
      expect(database_script).to receive(:results).once.and_return :stubbed

      database_script.send :cached_results
      database_script.send :cached_results
    end

    it "handles nil" do
      expect(database_script).to receive(:results).once.and_return nil

      database_script.send :cached_results
      database_script.send :cached_results
    end

    it "handles false" do
      expect(database_script).to receive(:results).once.and_return false

      database_script.send :cached_results
      database_script.send :cached_results
    end

    DatabaseScript.all.each do |database_script|
      it "#{database_script.filename_without_extension} calls `#results` only once" do
        if database_script.respond_to? :results
          expect(database_script).to receive(:results).at_most(:once).and_call_original
        end
        database_script.render
      end
    end
  end

  describe "testsing with a real script" do
    let(:script) { DatabaseScripts::ValidTaxaListedAsAnotherTaxonsJuniorSynonym.new }

    describe "#to_param" do
      it "is the filename without extension" do
        expect(script.to_param).to eq "valid_taxa_listed_as_another_taxons_junior_synonym"
      end
    end

    describe "#description" do
      it "can have a description" do
        expect(script.description).to match "See %github279."
      end

      it "doesn't require a description" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.description).to eq ""
      end
    end

    describe "#tags" do
      it "can have tags" do
        expect(script.tags).to eq ["regression-test"]
      end

      it "doesn't require tags" do
        allow(script).to receive(:end_data).and_return HashWithIndifferentAccess.new
        expect(script.tags).to eq []
      end
    end
  end
end
