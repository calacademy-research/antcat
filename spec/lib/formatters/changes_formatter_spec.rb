# coding: UTF-8
require 'spec_helper'

describe Formatters::ChangesFormatter do
  describe "Formatting approver name" do
    it "should call Formatters::CatalogFormatter" do
      approver = FactoryGirl.create :editor, name: 'Brian Fisher'
      string = Formatters::ChangesFormatter.format_approver_name(approver)
      expect(string).to match(/Brian Fisher/)
      expect(string).to match(/approved this change/)
    end
  end
end
