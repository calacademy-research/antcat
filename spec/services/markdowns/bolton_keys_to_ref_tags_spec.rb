# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::BoltonKeysToRefTags do
  describe "#call" do
    let!(:latreille) { create :any_reference, bolton_key: "Latreille 1802c" }

    context "when content contains a matching reference" do
      specify { expect(described_class["Latreille, 1802c: 236;"]).to eq "{#{Taxt::REF_TAG} #{latreille.id}}: 236;" }

      context "without trailing semicolon" do
        specify { expect(described_class["Latreille, 1802c: 236"]).to eq "{#{Taxt::REF_TAG} #{latreille.id}}: 236" }
      end

      context "with ampersand in the key" do
        let!(:agosti) { create :any_reference, bolton_key: "Agosti Wood 1987b" }

        specify do
          expect(described_class["Agosti & Wood, 1987b: 236"]).to eq "{#{Taxt::REF_TAG} #{agosti.id}}: 236"
        end
      end

      context "with 'et al.' in the key" do
        let!(:agosti) { create :any_reference, bolton_key: "Agosti et al. 1987b" }

        specify do
          expect(described_class["Agosti et al., 1987b: 236"]).
            to eq "{#{Taxt::REF_TAG} #{agosti.id}}: 236"
        end
      end

      context "with prefixed group title" do
        let(:content) { "Status as species: Latreille, 1802c: 236;" }

        it "maintains the spacing after the group title" do
          expect(described_class[content]).to eq "Status as species: {#{Taxt::REF_TAG} #{latreille.id}}: 236;"
        end
      end
    end

    context "when content contains multiple references" do
      let(:content) { "Latreille, 1802c: 236; Fisher, et al. 2002: 37" }

      context "when not all Bolton keys matches AntCat references" do
        it "replaces what it can and leaves the rest as is" do
          expect(described_class[content]).
            to eq "{#{Taxt::REF_TAG} #{latreille.id}}: 236; Fisher, et al. 2002: 37"
        end

        it "returns output that can safely be used as input again" do
          first_pass = described_class[content]
          expect(first_pass).to eq "{#{Taxt::REF_TAG} #{latreille.id}}: 236; Fisher, et al. 2002: 37"

          expect(described_class[first_pass]).to eq first_pass
        end
      end

      context "when both have matching Bolton keys on AntCat" do
        let!(:fisher_et_al) { create :any_reference, bolton_key: "Fisher et al. 2002" }

        specify do
          expect(described_class[content]).
            to eq "{#{Taxt::REF_TAG} #{latreille.id}}: 236; {#{Taxt::REF_TAG} #{fisher_et_al.id}}: 37"
        end
      end
    end
  end
end
