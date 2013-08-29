# coding: UTF-8
require 'spec_helper'

class FormattersButtonFormatterTestClass
  include Formatters::ButtonFormatter
end

describe Formatters::ButtonFormatter do
  before do
    @formatter = FormattersButtonFormatterTestClass.new
  end

  describe "Making a submit button" do
    it "should handle a primary priority button" do
      string = @formatter.submit_button 'Go', 'submit_button'
      string.should == "<input class=\"ui-button ui-corner-all ui-priority-primary\" id=\"submit_button\" type=\"submit\" value=\"Go\"></input>"
      string.should be_html_safe
    end
    it "should handle a secondary priority button" do
      string = @formatter.submit_button 'Cancel', 'cancel_button', secondary: true
      string.should == "<input class=\"ui-button ui-corner-all ui-priority-secondary\" id=\"cancel_button\" type=\"submit\" value=\"Cancel\"></input>" 
      string.should be_html_safe
    end
  end
end
