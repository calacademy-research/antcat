require "spec_helper"

describe TaxtPresenter do
  describe "#to_html" do
    context 'with unsafe tags' do
      let(:reference) { create :unknown_reference, citation: 'Latreille, 1809 <script>xss</script>' }

      it "sanitizes them" do
        expect(described_class["{ref #{reference.id}} <script>xss</script>"].to_html).to_not include 'script'
      end
    end

    it "handles nil" do
      expect(described_class[nil].to_html).to eq ''
    end

    specify { expect(described_class['string'].to_html).to be_html_safe }
  end

  describe "#to_antweb" do
    let(:taxt) { "{tax #{create(:family).id}}" }

    it "uses a different link formatter" do
      expect(described_class[taxt].to_antweb).to match "antcat.org"
    end

    describe 'broken taxt tags' do
      describe "ref tags (references)" do
        let(:results) { described_class["{ref 999}"].to_antweb }

        context "when the ref points to a reference that doesn't exist" do
          it "adds a warning" do
            expect(results).to eq "CANNOT FIND REFERENCE WITH ID 999"
          end
        end
      end

      describe "nam tags (names)" do
        context "when the name can't be found" do
          let(:results) { described_class["{nam 999}"].to_antweb }

          it "adds a warning" do
            expect(results).to eq "CANNOT FIND NAME WITH ID 999"
          end
        end
      end

      describe "tax tags (taxa)" do
        let(:results) { described_class["{tax 999}"].to_antweb }

        context "when the taxon can't be found" do
          it "adds a warning" do
            expect(results).to eq "CANNOT FIND TAXON WITH ID 999"
          end
        end
      end
    end
  end
end
