require 'spec_helper'

describe TaxtIdTranslator do
  it "converts to and from base 10" do
    expect(base_10_to_base_x(23, '0123456789')).to eq '23'
    expect(base_x_to_base_10('23', '0123456789')).to eq 23
  end

  it "converts base_10_to_base_x 11 to base 11" do
    expect(base_10_to_base_x(11, %{abcdefghijk})).to eq 'ba'
    expect(base_x_to_base_10('ba', %{abcdefghijk})).to eq 11
  end

  it "converts base_10_to_base_x to base 12" do
    expect(base_10_to_base_x(23, %{abcdefghijkl})).to eq 'bl'
    expect(base_x_to_base_10('bl', %{abcdefghijkl})).to eq 23
  end

  it "converts base_10_to_base_x to and from the base we want to use" do
    digits = %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!}
    expect(base_10_to_base_x(126798, digits)).to eq 'KP3'

    digits = %{0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$-_.+!*'(),)-=~`!}
    expect(base_x_to_base_10('KP3', digits)).to eq 126798
  end
end

def base_10_to_base_x number, digits
  TaxtIdTranslator.jumble_any_number number, digits
end

def base_x_to_base_10 number, digits
  TaxtIdTranslator.unjumble_any_number number, digits
end
