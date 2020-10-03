# frozen_string_literal: true

require 'rails_helper'

describe References::FulltextSearchLightQuery, :search do
  describe "#call" do
    describe "search queries" do
      context "when search query contains hyphens" do
        let!(:reference) { create :any_reference, author_string: "Casevitz-Weulersse" }

        before { Sunspot.commit }

        specify { expect(described_class["Casevitz-Weulersse"]).to eq [reference] }
        specify { expect(described_class["Casevitz Weulersse"]).to eq [reference] }
      end

      context "when search query contains '&'" do
        let!(:reference) { create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.'] }

        before { Sunspot.commit }

        specify { expect(described_class["Fisher & Bolton"]).to eq [reference] }
      end

      context "when search query contains 'et al.'" do
        let!(:reference) { create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.', 'Ward, P.S.'] }

        before { Sunspot.commit }

        specify { expect(described_class["Fisher, et al."]).to eq [reference] }
      end
    end

    describe "ordering" do
      context "when references have the same `year` but different `year_suffix`" do
        let!(:forel_a) { create :any_reference, author_string: "Forel", year: 1911, year_suffix: "a" }
        let!(:forel_b) { create :any_reference, author_string: "Forel", year: 1911, year_suffix: "b" }

        it "orders by suffixed year" do
          Sunspot.commit
          expect(described_class["Forel 1911"]).to eq [forel_a, forel_b]
        end

        context "when there is also a less relevant hit" do
          let!(:less_relevant) { create :any_reference, year: 1912, title: "Forel 1911 title hit" }

          it "orders by suffixed year and places less relevant hits last" do
            Sunspot.commit
            expect(described_class["Forel 1911"]).to eq [forel_a, forel_b, less_relevant]
          end
        end
      end
    end
  end
end
