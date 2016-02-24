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
    it "creates a link to the hide tribes action with all the current parameters" do
      helper.stub(:params).and_return({ id: 99 })
      expected = %Q[<a href="/catalog/hide_tribes?id=99">hide tribes</a>]
      expect(helper.send(:hide_link, 'tribes')).to eq expected
    end
    it "handles child params" do
      helper.stub(:params).and_return({ child: "none" })
      expected = %Q[<a href="/catalog/hide_tribes?child=none">hide tribes</a>]
      expect(helper.send(:hide_link, 'tribes')).to eq expected
    end
    it "handles child and id params at the same time" do
      helper.stub(:params).and_return({ id: 99, child: "none" })
      expected = %Q[<a href="/catalog/hide_tribes?child=none&id=99">hide tribes</a>]
      expect(helper.send(:hide_link, 'tribes')).to eq expected
    end
  end

  describe "Show child link" do
    it "creates a link to the show action" do
      helper.stub(:params).and_return({ id: 99 })
      expected = %Q[<a href="/catalog/show_tribes?id=99">show tribes</a>]
      expect(helper.send(:show_child_link, 'tribes')).to eq expected
    end
    it "handles child params" do
      helper.stub(:params).and_return({ child: "none" })
      expected = %Q[<a href="/catalog/hide_tribes?child=none">hide tribes</a>]
      expect(helper.send(:hide_link, 'tribes')).to eq expected
    end
    it "handles child and id params at the same time" do
      helper.stub(:params).and_return({ id: 99, child: "none" })
      expected = %Q[<a href="/catalog/hide_tribes?child=none&id=99">hide tribes</a>]
      expect(helper.send(:hide_link, 'tribes')).to eq expected
    end
  end

  describe "index column links" do
    it "#incertae_sedis_column_link" do
      formicidae = FactoryGirl.create :family
      expect(helper.incertae_sedis_column_link(:subfamily, 'none', 'none', formicidae))
        .to eq %[<a class="valid selected" href="/catalog/#{formicidae.id}?child=none">(no subfamily)</a>]
    end
    describe "#taxon_column_link" do
      it "formats selected" do
        selected = FactoryGirl.create :genus
        expect(helper.taxon_column_link(selected, selected))
          .to eq %[<a class="genus name selected taxon valid" href="/catalog/#{selected.id}"><i>#{selected.name}</i></a>]
      end
      it "formats non-selected" do
        selected = FactoryGirl.create :genus
        not_selected = FactoryGirl.create :genus
        expect(helper.taxon_column_link(selected, not_selected))
          .to eq %[<a class="genus name taxon valid" href="/catalog/#{selected.id}"><i>#{selected.name}</i></a>]
      end
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