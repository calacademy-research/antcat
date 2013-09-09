# coding: UTF-8
require 'spec_helper'

describe Formatters::ChangesFormatter do
  describe "Formatting approver name" do
    it "should call Formatters::CatalogFormatter" do
      approver = FactoryGirl.create :editor, name: 'Brian Fisher'
      string = Formatters::ChangesFormatter.format_approver_name(approver)
      string.should =~ /Brian Fisher/
      string.should =~ /approved this change/
    end
  end
end
