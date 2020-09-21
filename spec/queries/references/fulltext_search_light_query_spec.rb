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
        let!(:reference) do
          bolton = create :author_name, name: 'Bolton, B.'
          fisher = create :author_name, name: 'Fisher, B.'

          create :any_reference, author_names: [bolton, fisher]
        end

        before { Sunspot.commit }

        specify { expect(described_class["Fisher & Bolton"]).to eq [reference] }
      end

      context "when search query contains 'et al.'" do
        let!(:reference) do
          bolton = create :author_name, name: 'Bolton, B.'
          fisher = create :author_name, name: 'Fisher, B.'
          ward = create :author_name, name: 'Ward, P.S.'

          create :any_reference, author_names: [bolton, fisher, ward]
        end

        before { Sunspot.commit }

        specify { expect(described_class["Fisher, et al."]).to eq [reference] }
      end
    end

    describe "ordering" do
      let(:service) { described_class.new("Forel 1911") }

      context "when references have the same `year` but different `year_suffix`" do
        let!(:forel_a) { create :any_reference, author_string: "Forel", year: 1911, year_suffix: "a" }
        let!(:forel_b) { create :any_reference, author_string: "Forel", year: 1911, year_suffix: "b" }

        it "orders by suffixed year" do
          Sunspot.commit
          expect(service.call).to eq [forel_a, forel_b]
        end

        context "when there is also a less relevant hit" do
          let!(:less_relevant) do
            create :any_reference, author_string: "Other", year: 1912, title: "Forel 1911 title hit"
          end

          it "orders by suffixed year and places less relevant hits last" do
            Sunspot.commit
            expect(service.call).to eq [forel_a, forel_b, less_relevant]
          end
        end
      end
    end
  end
end
