# coding: UTF-8
require 'spec_helper'

describe Formatters::ChangesFormatter do
  describe "Formatting approver name" do
    it "should call Formatters::CatalogFormatter" do
      approver = double name: 'Mark'
      Formatters::ChangesFormatter.format_approver_name(approver).should == 'Mark approved this change'
    end
  end
end
