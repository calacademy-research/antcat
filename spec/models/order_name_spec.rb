# coding: UTF-8
require 'spec_helper'

describe OrderName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import order_name: 'Formicaria'
      expect(OrderName.find(name).name).to eq('Formicaria')
    end

  end

end
