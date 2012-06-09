# coding: UTF-8
require 'spec_helper'

describe GenusName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import '', genus_name: 'Atta'
      GenusName.find(name).name.should == 'Atta'
    end

  end

end



