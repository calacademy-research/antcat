require 'spec_helper'

describe CatalogHelper do
  describe "labels" do
    let(:taxon) { create :genus, name: create(:name, name: 'Atta') }

    describe "#taxon_label_span" do
      it "should create a span based on the type of the taxon and its status" do
        result = helper.taxon_label_span(taxon)
        expect(result).to eq('<span class="genus name taxon">Atta</span>')
        expect(result).to be_html_safe
      end
    end

    describe "#css_classes_for_rank" do
      it 'should return the right ones' do
        expect(helper.css_classes_for_rank(taxon)).to match_array(['genus', 'taxon', 'name'])
      end
    end

    describe "#css_classes_for_status" do
      it "should return the correct classes" do
        expect(helper.send(:css_classes_for_status, taxon)).to match_array ["valid"]
      end
      # Not tested: "nomen_nudum"/"collective_group_name"
    end
  end
end
