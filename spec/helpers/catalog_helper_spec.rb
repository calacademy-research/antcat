require 'spec_helper'

describe CatalogHelper do

  describe "search selector" do
    it "should return the HTML for the selector with a default selected" do
      expect(helper.search_selector(nil)).to eq(
          %{<select name=\"st\" id=\"st\"><option value=\"m\">matching</option>\n<option selected=\"selected\" value=\"bw\">beginning with</option>\n<option value=\"c\">containing</option></select>}
      )
    end
    it "should return the HTML for the selector with the specified one selected" do
      expect(helper.search_selector('c')).to eq(
          %{<select name=\"st\" id=\"st\"><option value=\"m\">matching</option>\n<option value=\"bw\">beginning with</option>\n<option selected=\"selected\" value=\"c\">containing</option></select>}
      )
    end
  end

  describe "#taxon_browser_link" do
    it "formats" do
      taxon = FactoryGirl.create :genus
      expect(helper.taxon_browser_link(taxon))
        .to eq %[<a class="genus name taxon valid" href="/catalog/#{taxon.id}"><i>#{taxon.name}</i></a>]
    end
  end

  # TODO add once the code is more stable
  # describe "#panel_header selected"
  # describe "#all_genera_link selected"
  # describe "#incertae_sedis_link selected"
  # describe "#toggle_valid_only_link"

  describe "labels" do
    let(:taxon) { FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta') }

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