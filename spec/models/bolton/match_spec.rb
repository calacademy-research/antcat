# coding: UTF-8
require 'spec_helper'

describe Bolton::Match do
  it "can have a reference" do
    match = Bolton::Match.create!
    match.reference = Factory :reference
  end

  it "can have a Bolton reference" do
    match = Bolton::Match.create!
    match.bolton_reference = Factory :bolton_reference
  end
end
