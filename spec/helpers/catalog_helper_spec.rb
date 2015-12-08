# coding: UTF-8
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

  describe "Hide link" do
    it "should create a link to the hide tribes action with all the current parameters" do
      taxon = FactoryGirl.create :genus
      expect(helper.hide_link('tribes', taxon, {})).to eq('<a href="/catalog/hide_tribes">hide</a>')
    end
  end

  describe "Show child link" do
    it "should create a link to the show action" do
      taxon = FactoryGirl.create :genus
      expect(helper.show_child_link('tribes', taxon, {})).to eq(%{<a href="/catalog/show_tribes">show tribes</a>})
    end
  end

  describe "Index column link" do
    it "should work" do
      expect(helper.index_column_link(:subfamily, 'none', 'none', nil)).to eq('<a class="valid selected" href="/catalog?child=none">(no subfamily)</a>')
    end
  end

  describe "#clear_search_results_link" do
    it "links the root path if no id is given" do
      id = nil
      clear_link = clear_search_results_link(id)
      expect(clear_link).to include root_path
      expect(clear_link).to_not include "catalog"
    end

    it "links the taxon if an id is given" do
      id = 101
      expect(clear_search_results_link(id)).to include catalog_path(id)
    end
  end

  describe "array snaking" do
    it "handles empty arrays" do
      expect(snake([], 1)).to eq []
    end
    it "handles arrays with single items" do
      expect(snake([1], 1)).to eq [[1]]
    end

    it "handles arrays with multiple items" do
      expect(snake([1, 2, 3, 4], 2)).to eq [[1, 3], [2, 4]]
    end

    it "handles empty cells" do
      expect(snake([1, 2, 3, 4, 5], 2)).to eq [[1, 4], [2, 5], [3, nil]]
    end

    it "puts all nil padding items at the end" do
      array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      manually_snaked = [
        [1, 4, 6, 8, 10],
        [2, 5, 7, 9, 11],
        [3, nil, nil, nil, nil]
      ]
      expect(snake(array, 5)).to eq manually_snaked
    end
  end

  describe "labels" do
    let(:taxon) { FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta') }

    describe "Taxon label span" do
      it "should create a span based on the type of the taxon and its status" do
        result = helper.taxon_label_span(taxon)
        expect(result).to eq('<span class="genus name taxon valid">Atta</span>')
        expect(result).to be_html_safe
      end
    end

    describe 'taxon label and css classes' do
      it "should return the CSS class based on the type of the taxon and its status" do
        taxon_label_and_css_classes = helper.taxon_label_and_css_classes(taxon)
        expect(taxon_label_and_css_classes[:label]).to eq('Atta')
        expect(taxon_label_and_css_classes[:css_classes]).to eq('genus name taxon valid')
      end
      it "should prepend a fossil symbol" do
        taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :fossil => true
        expect(helper.taxon_label_and_css_classes(taxon)[:label]).to eq('&dagger;Atta')
      end
      it "should handle being selected" do
        expect(helper.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes]).to eq('genus name selected taxon valid')
      end
      it "should handle upper case" do
        expect(helper.taxon_label_and_css_classes(taxon, :uppercase => true)[:label]).to eq('ATTA')
      end
      it "should return an HTML safe label" do
        expect(helper.taxon_label_and_css_classes(taxon)[:label]).to be_html_safe
      end
    end

    describe 'taxon rank css classes' do
      it 'should return the right ones' do
        expect(helper.css_classes_for_rank(taxon)).to match_array(['genus', 'taxon', 'name'])
      end
    end

    describe 'taxon class' do
      it "should return the correct classes" do
        expect(helper.send(:taxon_css_classes, taxon)).to eq("genus name taxon valid")
      end
    end

    describe "PDF link formatting" do
      it "should create a link" do
        reference = FactoryGirl.create :reference
        allow(reference).to receive(:downloadable_by?).and_return true
        allow(reference).to receive(:url).and_return 'example.com'
        expect(reference.decorate.format_reference_document_link).to eq('<a class="document_link" href="example.com" target="_blank">PDF</a>')
      end
    end
  end

end