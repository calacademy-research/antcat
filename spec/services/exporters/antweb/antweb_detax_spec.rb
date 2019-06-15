require "spec_helper"

describe Exporters::Antweb::AntwebDetax do
  describe "#call" do
    let(:taxt) { "{tax #{create(:family).id}}" }

    it "uses a different link formatter" do
      expect(described_class[taxt]).to match "antcat.org"
    end

    describe 'broken taxt tags' do
      describe "ref tags (references)" do
        let(:results) { described_class["{ref 999}"] }

        context "when the ref points to a reference that doesn't exist" do
          it "adds a warning" do
            expect(results).to eq "CANNOT FIND REFERENCE WITH ID 999"
          end
        end
      end

      describe "tax tags (taxa)" do
        let(:results) { described_class["{tax 999}"] }

        context "when the taxon can't be found" do
          it "adds a warning" do
            expect(results).to eq "CANNOT FIND TAXON WITH ID 999"
          end
        end
      end
    end
  end
end
