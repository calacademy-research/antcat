# coding: UTF-8
require 'spec_helper'

describe Taxt do
  describe "Encodings" do
    it "should encode an unparseable string" do
      Taxt.unparseable('foo').should == '{? foo}'
    end
    it "should encode an unparseable string" do
      reference = Factory :book_reference
      Taxt.reference(reference).should == "{ref #{reference.id}}"
    end
  end
end
