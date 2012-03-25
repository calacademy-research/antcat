# coding: UTF-8
require 'spec_helper'

describe AnyBase do

  it "should convert to and from base 10" do
    AnyBase.base_10_to_base_x(23, '0123456789').should == '23'
    AnyBase.base_x_to_base_10('23', '0123456789').should == 23
  end

  it "should base_10_to_base_x 11 to base 11" do
    AnyBase.base_10_to_base_x(11, %{abcdefghijk}).should == 'ba'
    AnyBase.base_x_to_base_10('ba', %{abcdefghijk}).should == 11
  end

  it "should base_10_to_base_x to base 12" do
    AnyBase.base_10_to_base_x(23, %{abcdefghijkl}).should == 'bl'
    AnyBase.base_x_to_base_10('bl', %{abcdefghijkl}).should == 23
  end

  it "should base_10_to_base_x to and from the base we want to use" do
    AnyBase.base_10_to_base_x(126798, %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!}).should == 'KP3'
    AnyBase.base_x_to_base_10('KP3', %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!}).should == 126798
  end

end
