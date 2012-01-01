# coding: UTF-8
require 'spec_helper'

describe MissingReferenceKey do

  describe "Link" do
    it "should simply output its citation" do
      key = MissingReferenceKey.new("citation")
      key.to_link.should == 'citation'
    end
  end

end
