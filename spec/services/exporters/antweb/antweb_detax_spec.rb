require 'rails_helper'

describe Exporters::Antweb::AntwebDetax do
  describe "#call" do
    describe "tax tags (taxa)" do
      let!(:taxon) { create :family }

      specify do
        results = described_class["{tax #{taxon.id}}"]

        expect(results).to include taxon.name_cache
        expect(results).to include "antcat.org"
      end
    end

    describe "ref tags (references)" do
      let!(:reference) { create :article_reference }

      specify do
        results = described_class["{ref #{reference.id}}"]

        expect(results).to include reference.title
        expect(results).to include "antcat.org"
      end
    end
  end
end
