# coding: UTF-8
require 'exporters/advanced_search_exporter'

describe Exporters::AdvancedSearchExporter do
  it "should format a taxon" do
    exporter = Exporters::AdvancedSearchExporter.new
    debugger

    exporter.export(nil).should == 'asdf'
  end
end

