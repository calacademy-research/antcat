require 'rails_helper'

describe MissingReference do
  describe 'validations' do
    it { is_expected.to allow_value(nil).for :year }
    it { is_expected.to allow_values('1990', '1990b').for(:citation_year) }
    it { is_expected.to_not allow_values('199', '1990 "1991"', '19900', '1990bb').for(:citation_year) }
  end

  describe "#keey" do
    let(:reference) { build_stubbed :missing_reference, citation: "citation" }

    specify { expect(reference.keey).to be_html_safe }

    context "when no citation_year" do
      before { reference.citation_year = nil }

      specify { expect(reference.keey).to eq %(<span class="bold-warning">[missing reference]</span> citation, [no year]) }
    end

    context "when there is a citation_year" do
      before { reference.citation_year = 2000 }

      it "includes the year" do
        expect(reference.keey).to eq %(<span class="bold-warning">[missing reference]</span> citation, 2000)
      end

      context "when citation contains a year" do
        before { reference.citation = "citation 1999a" }

        it "uses the citation only" do
          expect(reference.keey).to eq %(<span class="bold-warning">[missing reference]</span> citation 1999a)
        end
      end
    end
  end
end
