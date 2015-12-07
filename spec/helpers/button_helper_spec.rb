# coding: UTF-8
require 'spec_helper'

describe ButtonHelper do
  describe "Making a button" do
    it "should handle a button with an id" do
      string = helper.button 'Button'
      expect(string).to eq("<input class=\"ui-button ui-corner-all ui-priority-primary\" id=\"button_button\" type=\"button\" value=\"Button\"></input>")
    end
  end

  describe "Making a submit button" do
    it "should return an html_safe string" do
      string = helper.submit_button 'Go', 'submit_button'
      expect(string).to be_html_safe
    end
    it "should handle a primary priority button" do
      string = helper.submit_button 'Go', 'submit_button'
      expect(string).to eq("<input class=\"submit ui-button ui-corner-all ui-priority-primary\" id=\"submit_button\" type=\"submit\" value=\"Go\"></input>")
    end
    it "should handle a secondary priority button" do
      string = helper.submit_button 'Cancel', 'cancel_button', secondary: true
      expect(string).to eq("<input class=\"submit ui-button ui-corner-all ui-priority-secondary\" id=\"cancel_button\" type=\"submit\" value=\"Cancel\"></input>")
      expect(string).to be_html_safe
    end
    it "should default the ID" do
      string = helper.submit_button 'Cancel'
      expect(string).to eq("<input class=\"submit ui-button ui-corner-all ui-priority-primary\" id=\"cancel_button\" type=\"submit\" value=\"Cancel\"></input>")
    end
  end

  describe "Making a cancel button" do
    it "should handle a cancel button" do
      string = helper.cancel_button
      expect(string).to eq("<input class=\"cancel ui-button ui-corner-all ui-priority-secondary\" id=\"cancel_button\" type=\"button\" value=\"Cancel\"></input>")
    end
  end

  describe "Making a button to a path" do
    it "should handle making a button to a path" do
      string = helper.button_to_path 'Label', 'path'
      expect(string).to eq("<form class=\"button_to\" method=\"post\" action=\"path\"><input class=\"ui-button ui-corner-all ui-priority-primary\" type=\"submit\" value=\"Label\" /></form>")
      expect(string).to be_html_safe
    end
  end

end
