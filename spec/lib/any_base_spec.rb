require 'spec_helper'

describe AnyBase do

  it "should convert to and from base 10" do
    expect(AnyBase.base_10_to_base_x(23, '0123456789')).to eq('23')
    expect(AnyBase.base_x_to_base_10('23', '0123456789')).to eq(23)
  end

  it "should base_10_to_base_x 11 to base 11" do
    expect(AnyBase.base_10_to_base_x(11, %{abcdefghijk})).to eq('ba')
    expect(AnyBase.base_x_to_base_10('ba', %{abcdefghijk})).to eq(11)
  end

  it "should base_10_to_base_x to base 12" do
    expect(AnyBase.base_10_to_base_x(23, %{abcdefghijkl})).to eq('bl')
    expect(AnyBase.base_x_to_base_10('bl', %{abcdefghijkl})).to eq(23)
  end

  it "should base_10_to_base_x to and from the base we want to use" do
    expect(AnyBase.base_10_to_base_x(126798, %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!})).to eq('KP3')
    expect(AnyBase.base_x_to_base_10('KP3', %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!})).to eq(126798)
  end

end
