require 'spec_helper'

describe LayoutsHelper do
  describe '#subnavigation_menu' do
    it "puts bars between the items" do
      expect(helper.subnavigation_menu(['a', 'b'])).to eq '<span>a | b</span>'
    end

    it "is html_safe" do
      expect(helper.subnavigation_menu(['a', 'b'])).to be_html_safe
    end
  end
end
