# coding: UTF-8
require 'spec_helper'

describe CatalogHelper do

  describe "search selector" do
    it "should return the HTML for the selector with a default selected" do
      helper.search_selector(nil).should == 
%{<select id="search_type" name="search_type"><option value="matching">matching</option>\n<option value="beginning with" selected="selected">beginning with</option>\n<option value="containing">containing</option></select>}
    end
    it "should return the HTML for the selector with the specified one selected" do
      helper.search_selector('containing').should == 
%{<select id="search_type" name="search_type"><option value="matching">matching</option>\n<option value="beginning with">beginning with</option>\n<option value="containing" selected="selected">containing</option></select>}
    end
  end

  describe "Delegation to CatalogFormatter" do
    it "status labels" do
      CatalogFormatter.should_receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      CatalogFormatter.should_receive(:format_statistics).with(1, include_invalid: true)
      helper.format_statistics 1, true
    end
  end

end
