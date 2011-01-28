require 'spec_helper'

describe ReferenceHelper do
  before do
  end
  it "#format_reference should delegate to the formatter" do
    ReferenceFormatter.should_receive :format
    helper.format_reference  Factory :reference
  end
  it "#italicize should delegate to the formatter" do
    ReferenceFormatter.should_receive :italicize
    helper.italicize 'string'
  end
  it "#format_timestamp should delegate to the formatter" do
    ReferenceFormatter.should_receive :format_timestamp
    helper.format_timestamp Time.new
  end
end
