# coding: UTF-8
require 'spec_helper'

describe Exporters::AdvancedSearchExporter do
  it "should format a taxon" do
    reference = FactoryGirl.create :article_reference, author_names: [AuthorName
    create_genus 'Atta'
    exporter = Exporters::AdvancedSearchExporter.new
    exporter.export(nil).should == %{Atta Fisher, B.L. 2013d. Ants are my life. Ants 3:3.}
  end
end

