# coding: UTF-8
require 'spec_helper'

describe Taxt do
  describe "Encodings" do
    it "should encode an unparseable string" do
      Taxt.unparseable('foo').should == '{? foo}'
    end
  end
end
