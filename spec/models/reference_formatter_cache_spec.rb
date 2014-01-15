# coding: UTF-8
require 'spec_helper'

describe ReferenceFormatterCache do
  it "is a singleton" do
    -> {ReferenceFormatterCache.new}.should raise_error
    ReferenceFormatterCache.instance.should ==  ReferenceFormatterCache.instance
  end
end
