require 'spec_helper'

describe MissingReference do
  it { should allow_value(nil).for :year }

  describe "#keey" do
    let(:reference) { build_stubbed :missing_reference, citation: "citation" }

    it "is html_safe" do
      expect(reference.keey).to be_html_safe
    end

    context "no citation_year" do
      before { reference.citation_year = nil }

      it "handles it" do
        expect(reference.keey).to eq "citation, [no year]"
      end
    end

    context "there is a citation_year" do
      before { reference.citation_year = 2000 }

      it "includes the year" do
        expect(reference.keey).to eq "citation, 2000"
      end

      context "citation contains a year" do
        before { reference.citation = "citation 1999a" }

        it "uses the citation only" do
          expect(reference.keey).to eq "citation 1999a"
        end
      end
    end
  end
end
