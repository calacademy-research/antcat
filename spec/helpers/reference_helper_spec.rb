# coding: UTF-8
require 'spec_helper'

describe ReferenceHelper do
  before do
  end
  it "#format_reference should delegate to the formatter" do
    Formatters::ReferenceFormatter.should_receive :format
    helper.format_reference  FactoryGirl.create :reference
  end
  #it "#format_reference_document_link should delegate to the formatter" do
    #Formatters::CatalogFormatter.should_receive :format_reference_document_link
    # problem with calling 'current_user' in the helper
    #helper.format_reference_document_link  FactoryGirl.create :reference
  #end
  it "#format_italics should delegate to the formatter" do
    Formatters::ReferenceFormatter.should_receive :format_italics
    helper.format_italics 'string'
  end
  it "#format_timestamp should delegate to the formatter" do
    Formatters::ReferenceFormatter.should_receive :format_timestamp
    helper.format_timestamp Time.new
  end
end
