require 'spec_helper'

describe CatalogHelper do
  # Moved to `TaxonDecorator::ChildList`.
  describe "labels" do
    let(:taxon) { create :genus, name: create(:name, name: 'Atta') }

    xdescribe "#taxon_label_span" do
      it "creates a span based on the type of the taxon and its status" do
        result = helper.taxon_label_span taxon
        expect(result).to eq '<span class="genus name taxon">Atta</span>'
        expect(result).to be_html_safe
      end
    end

    xdescribe "#css_classes_for_rank" do
      it 'returns the right ones' do
        expect(helper.css_classes_for_rank(taxon)).to match_array ['genus', 'taxon', 'name']
      end
    end
  end
end
