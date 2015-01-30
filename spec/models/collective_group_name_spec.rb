# coding: UTF-8
require 'spec_helper'

describe CollectiveGroupName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import collective_group_name: 'Myrmiciites'
      expect(CollectiveGroupName.find(name).name).to eq('Myrmiciites')
    end

  end

end
