# coding: UTF-8
require 'spec_helper'

describe TribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import tribe_name: 'Aneuretini'
      TribeName.find(name).name.should == 'Aneuretini'
    end

  end

end

