require 'spec_helper'

describe ButtonHelper do
  describe "Making a button" do
    it "should handle a button with an id" do
      string = helper.button 'Button'
      expect(string).to eq("<input class=\"\" id=\"button_button\" type=\"button\" value=\"Button\"></input>")
    end
  end
end
