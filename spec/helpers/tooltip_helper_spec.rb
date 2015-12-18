require 'spec_helper'

describe TooltipHelper do
  describe "#parse_lookup_params" do
    it "handles strings" do
      parsed = helper.send(:parse_lookup_params, "references.authors")
      expect(parsed).to eq "references.authors"
    end

    it "handles symbols" do
      parsed = helper.send(:parse_lookup_params, :no_namespace)
      expect(parsed).to eq "no_namespace"
    end

    describe "using scopes" do
      it "handles strings" do
        parsed = helper.send(:parse_lookup_params, "authors", scope: "references")
        expect(parsed).to eq "references.authors"
      end

      it "handles symbols" do
        parsed = helper.send(:parse_lookup_params, :authors, scope: :references)
        expect(parsed).to eq "references.authors"
      end
    end
  end
end
