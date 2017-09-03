require "spec_helper"

describe DatabaseScripts::DatabaseScript do
  let(:script) { DatabaseTestScript.new }

  describe ".new_from_filename_without_extension" do
    it "initializes" do
      results = described_class.new_from_filename_without_extension "SubspeciesWithoutSpecies"
      expect(results).to be_a DatabaseScripts::Scripts::SubspeciesWithoutSpecies
    end
  end

  describe "#cached_results" do
    it "doesn't call `#result` more than once" do
      expect(script).to receive(:results).once.and_return :stubbed

      script.send :cached_results
      script.send :cached_results
    end

    it "handles nil" do
      expect(script).to receive(:results).once.and_return nil

      script.send :cached_results
      script.send :cached_results
    end

    it "handles false" do
      expect(script).to receive(:results).once.and_return false

      script.send :cached_results
      script.send :cached_results
    end
  end

  describe "testsing with a real script" do
    let(:script) { DatabaseScripts::Scripts::BadSubfamilyNames.new }

    describe "#to_param" do
      it "is the filename without extension" do
        expect(script.to_param).to eq "bad_subfamily_names"
      end
    end

    describe "#description" do
      it "can have a description" do
        expect(script.description).to match "From %github71."
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
