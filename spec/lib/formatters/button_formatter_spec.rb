# coding: UTF-8
require 'spec_helper'

class FormattersButtonFormatterTestClass
  include Formatters::ButtonFormatter

  def protect_against_forgery?
    false
  end
end

describe Formatters::ButtonFormatter do
  before do
    @formatter = FormattersButtonFormatterTestClass.new
  end

  describe "Making a button" do
    it "should handle a button with an id" do
      string = @formatter.button 'Button'
      string.should == "<input class=\"ui-button ui-corner-all ui-priority-primary\" id=\"button_button\" type=\"button\" value=\"Button\"></input>"
    end
  end

  describe "Making a submit button" do
    it "should return an html_safe string" do
      string = @formatter.submit_button 'Go', 'submit_button'
      string.should be_html_safe
    end
    it "should handle a primary priority button" do
      string = @formatter.submit_button 'Go', 'submit_button'
      string.should == "<input class=\"submit ui-button ui-corner-all ui-priority-primary\" id=\"submit_button\" type=\"submit\" value=\"Go\"></input>"
    end
    it "should handle a secondary priority button" do
      string = @formatter.submit_button 'Cancel', 'cancel_button', secondary: true
      string.should == "<input class=\"submit ui-button ui-corner-all ui-priority-secondary\" id=\"cancel_button\" type=\"submit\" value=\"Cancel\"></input>"
      string.should be_html_safe
    end
    it "should default the ID" do
      string = @formatter.submit_button 'Cancel'
      string.should == "<input class=\"submit ui-button ui-corner-all ui-priority-primary\" id=\"cancel_button\" type=\"submit\" value=\"Cancel\"></input>"
    end
  end

  describe "Making a cancel button" do
    it "should handle a cancel button" do
      string = @formatter.cancel_button
      string.should == "<input class=\"cancel ui-button ui-corner-all ui-priority-secondary\" id=\"cancel_button\" type=\"button\" value=\"Cancel\"></input>"
    end
  end

  describe "Making a button to a path" do
    it "should handle making a button to a path" do
      string = @formatter.button_to_path 'Label', 'path'
      string.should == "<form action=\"path\" class=\"button_to\" method=\"post\"><div><input class=\"ui-button ui-corner-all ui-priority-primary\" type=\"submit\" value=\"Label\" /></div></form>"
      string.should be_html_safe
    end
  end

end
