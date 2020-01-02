require 'rails_helper'

describe References::Search::FulltextLight, :search do
  describe "#call" do
    describe "search queries" do
      context "when search query contains hyphens" do
        let!(:reference) { create :reference, author_name: "Casevitz-Weulersse" }

        before { Sunspot.commit }

        specify { expect(described_class["Casevitz-Weulersse"]).to eq [reference] }
        specify { expect(described_class["Casevitz Weulersse"]).to eq [reference] }
      end

      context "when search query contains '&'" do
        let!(:reference) do
          bolton = create :author_name, name: 'Bolton, B.'
          fisher = create :author_name, name: 'Fisher, B.'

          create :article_reference, author_names: [bolton, fisher], citation_year: '1970a'
        end

        before { Sunspot.commit }

        specify { expect(described_class["Fisher & Bolton 1970a"]).to eq [reference] }
      end

      context "when search query contains 'et al.'" do
        let!(:reference) do
          bolton = create :author_name, name: 'Bolton, B.'
          fisher = create :author_name, name: 'Fisher, B.'
          ward = create :author_name, name: 'Ward, P.S.'

          create :article_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
        end

        before { Sunspot.commit }

        specify { expect(described_class["Fisher, et al. 1970a"]).to eq [reference] }
      end
    end

    describe "ordering" do
      let(:service) { described_class.new("Forel 1911") }

      context "when references have the same year but different citation years" do
        let!(:forel_a) { create :reference, author_name: "Forel", citation_year: "1911a" }
        let!(:forel_b) { create :reference, author_name: "Forel", citation_year: "1911b" }

        it "orders by citation year" do
          Sunspot.commit
          expect(service.call).to eq [forel_a, forel_b]
        end

        context "when there is also a less relevant hit" do
          let!(:less_relevant) do
            create :reference, author_name: "Other", citation_year: "1912", title: "Forel 1911 was here"
          end

          it "orders by citation year and places less relevant hits last" do
            Sunspot.commit
            expect(service.call).to eq [forel_a, forel_b, less_relevant]
          end
        end
      end
    end
  end
end
