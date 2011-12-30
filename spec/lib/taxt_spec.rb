# coding: UTF-8
require 'spec_helper'

describe Taxt do
  describe "Encodings" do
    it "should encode an unparseable string" do
      Taxt.unparseable('foo').should == '{? foo}'
    end
    it "should encode a reference that wasn't found" do
      Taxt.unknown_reference('Latreille, 1909').should == '{ref? Latreille, 1909}'
    end
  end
end
