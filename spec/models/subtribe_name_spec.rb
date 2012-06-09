# coding: UTF-8
require 'spec_helper'

describe SubtribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import '', subtribe_name: 'Aneuretina'
      SubtribeName.find(name).name.should == 'Aneuretina'
    end

  end

end


