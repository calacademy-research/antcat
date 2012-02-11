# coding: UTF-8
require 'spec_helper'

describe ReferencesController do
  render_views

  it "should use the right exporter" do
    fisher_reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Fisher, B.L.')]
    fisher_formatter = mock
    Exporters::Endnote::Formatter::Article.should_receive(:new).with(fisher_reference).and_return fisher_formatter
    fisher_formatter.should_receive(:format).and_return "Fisher\n"

    bolton_reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton, B.L.')]
    bolton_formatter = mock
    Exporters::Endnote::Formatter::Article.should_receive(:new).with(bolton_reference).and_return bolton_formatter
    bolton_formatter.should_receive(:format).and_return "Bolton\n"

    get 'index', :format => 'endnote_import'
    response.body.should == "Bolton\n\nFisher\n\n"
  end

end
