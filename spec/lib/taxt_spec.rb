# coding: UTF-8
require 'spec_helper'

describe Taxt do

  describe "Encodings" do
    it "should encode an unparseable string" do
      Taxt.unparseable('foo').should == '{? foo}'
    end
    it "should encode a reference" do
      reference = Factory :book_reference
      Taxt.reference(reference).should == "{ref #{reference.id}}"
    end
    it "should put italics back around taxon names" do
      Taxt.taxon_name(genus_name: 'Atta').should == "<i>Atta</i>"
    end
    it "should put a dagger in front" do
      Taxt.taxon_name(genus_name:'Atta', fossil:true).should == "<i>&dagger;Atta</i>"
    end
  end

  describe "Interpolation" do

    it "should leave alone a string without fields" do
      Taxt.interpolate('foo').should == 'foo'
    end
    it "should handle nil" do
      Taxt.interpolate(nil).should == ''
    end
    it "should format a ref" do
      reference = Factory :article_reference
      Reference.should_receive(:find).with(reference.id.to_s).and_return reference
      key_stub = stub
      reference.should_receive(:key).and_return key_stub
      key_stub.should_receive(:to_link).and_return('foo')
      Taxt.interpolate("{ref #{reference.id}}").should == 'foo'
    end
    it "should not freak if the ref is malformed" do
      Taxt.interpolate("{ref sdf}").should == '{ref sdf}'
    end
    it "should not freak if the ref points to a reference that doesn't exist" do
      Taxt.interpolate("{ref 12345}").should == '{ref 12345}'
    end
    it "should handle a MissingReference" do
      reference = Factory :missing_reference, :citation => 'Latreille, 1809'
      Taxt.interpolate("{ref #{reference.id}}").should == 'Latreille, 1809'
    end

  end

end
