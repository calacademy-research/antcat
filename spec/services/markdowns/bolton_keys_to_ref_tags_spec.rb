require "spec_helper"

describe Markdowns::BoltonKeysToRefTags do
  describe "#call" do
    let!(:latreille) { reference_factory bolton_key: "Latreille 1802c", author_name: "no" }

    context "when content contains a matching reference" do
      specify { expect(described_class["Latreille, 1802c: 236;"]).to eq "{ref #{latreille.id}}: 236;" }

      context "without trailing semicolon" do
        specify { expect(described_class["Latreille, 1802c: 236"]).to eq "{ref #{latreille.id}}: 236" }
      end

      context "with prefixed group title" do
        let(:content) { "Status as species: Latreille, 1802c: 236;" }

        it "maintains the spacing after the group title" do
          expect(described_class[content]).to eq "Status as species: {ref #{latreille.id}}: 236;"
        end
      end
    end

    context "when content contains multiple references" do
      let(:content) { "Latreille, 1802c: 236; Fisher, et al. 2002: 37" }

      context "when not all Bolton keys matches AntCat references" do
        it "replaces what it can and leaves the rest as is" do
          expect(described_class[content]).to eq "{ref #{latreille.id}}: 236; Fisher, et al. 2002: 37"
        end

        it "returns output that can safely be used as input again" do
          first_pass = described_class[content]
          expect(first_pass).to eq "{ref #{latreille.id}}: 236; Fisher, et al. 2002: 37"

          expect(described_class[first_pass]).to eq first_pass
        end
      end

      context "when both have matching Bolton keys on AntCat" do
        let!(:fisher_et_al) { reference_factory bolton_key: "Fisher et al. 2002", author_name: "no" }

        specify { expect(described_class[content]).to eq "{ref #{latreille.id}}: 236; {ref #{fisher_et_al.id}}: 37" }
      end
    end
  end
end
