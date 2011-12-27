# coding: UTF-8
require 'spec_helper'

describe ReferenceHelper do
  before do
  end
  it "#format_reference should delegate to the formatter" do
    ReferenceFormatter.should_receive :format
    helper.format_reference  Factory :reference
  end
  #it "#format_reference_document_link should delegate to the formatter" do
    #CatalogFormatter.should_receive :format_reference_document_link
    # problem with calling 'current_user' in the helper
    #helper.format_reference_document_link  Factory :reference
  #end
  it "#italicize should delegate to the formatter" do
    ReferenceFormatter.should_receive :italicize
    helper.italicize 'string'
  end
  it "#format_timestamp should delegate to the formatter" do
    ReferenceFormatter.should_receive :format_timestamp
    helper.format_timestamp Time.new
  end
end
