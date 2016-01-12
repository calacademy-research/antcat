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
      expected = %Q[<a href="/catalog/hide_tribes?id=#{taxon.id}">hide</a>]
      expect(helper.hide_link('tribes', taxon.id, nil)).to eq expected
    end
  end

  describe "Show child link" do
    it "should create a link to the show action" do
      taxon = FactoryGirl.create :genus
      expected = %Q[<a href="/catalog/show_tribes?id=#{taxon.id}">show tribes</a>]
      expect(helper.show_child_link('tribes', taxon.id, nil)).to eq expected
    end
  end

  describe "Index column link" do
    it "should work" do
      expect(helper.index_column_link(:subfamily, 'none', 'none', nil)).to eq('<a class="valid selected" href="/catalog?child=none">(no subfamily)</a>')
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
      expect(snake([1, 2, 3, 4, 5], 2)).to eq [[1, 4], [2, 5], [3]]
    end

    it "doesn't pad with nil" do
      array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      manually_snaked = [
        [1, 4, 6, 8, 10],
        [2, 5, 7, 9, 11],
        [3]
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
  end

end