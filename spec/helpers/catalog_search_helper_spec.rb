require 'spec_helper'

describe CatalogSearchHelper do
  describe "#search_type_selector" do
    it "should return the HTML for the selector with a default selected" do
      expect(helper.search_type_selector(nil)).to eq(
        %{<select name=\"search_type\" id=\"search_type\"><option value=\"matching\">Matching</option>\n<option selected=\"selected\" value=\"beginning_with\">Beginning with</option>\n<option value=\"containing\">Containing</option></select>}
      )
    end
    it "should return the HTML for the selector with the specified one selected" do
      expect(helper.search_type_selector('containing')).to eq(
        %{<select name=\"search_type\" id=\"search_type\"><option value=\"matching\">Matching</option>\n<option value=\"beginning_with\">Beginning with</option>\n<option selected=\"selected\" value=\"containing\">Containing</option></select>}
      )
    end
  end
end
