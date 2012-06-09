# coding: UTF-8
require 'spec_helper'

describe SubfamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import subfamily_name: 'Aneuretinae'
      SubfamilyName.find(name).name.should == 'Aneuretinae'
    end
  end

end
