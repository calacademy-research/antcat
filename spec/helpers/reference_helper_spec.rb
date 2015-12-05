# coding: UTF-8
require 'spec_helper'

describe ReferenceHelper do
  before do
  end
  it "#format_reference should delegate to the formatter" do
    expect(Formatters::ReferenceFormatter).to receive :format
    helper.format_reference FactoryGirl.create :reference
  end
  it "#format_italics should delegate to the formatter" do
    expect(Formatters::ReferenceFormatter).to receive :format_italics
    helper.format_italics 'string'
  end
  it "#format_timestamp should delegate to the formatter" do
    expect(Formatters::ReferenceFormatter).to receive :format_timestamp
    helper.format_timestamp Time.new
  end
end
