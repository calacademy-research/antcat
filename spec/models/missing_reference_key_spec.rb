# coding: UTF-8
require 'spec_helper'

describe MissingReferenceKey do

  describe "Link" do
    it "should simply output its citation" do
      key = MissingReferenceKey.new("citation")
      expect(key.to_link).to eq('citation')
    end
  end

  describe "Unapplicable methods" do
    it "should just return nil from them" do
      key = MissingReferenceKey.new('citation')
      expect(key.document_link(FactoryGirl.create :user)).to be_nil
      expect(key.goto_reference_link).to be_nil
    end
  end

end
