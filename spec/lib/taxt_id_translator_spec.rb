require 'spec_helper'

describe TaxtIdTranslator do
  describe ".base_10_to_base_x and .base_x_to_base_10" do
    describe "bases we don't use" do
      it "converts to and from base 10" do
        expect(base_10_to_base_x(23, '0123456789')).to eq '23'
        expect(base_x_to_base_10('23', '0123456789')).to eq 23
      end

      it "converts base_10_to_base_x 11 to base 11" do
        expect(base_10_to_base_x(11, %(abcdefghijk))).to eq 'ba'
        expect(base_x_to_base_10('ba', %(abcdefghijk))).to eq 11
      end

      it "converts base_10_to_base_x to base 12" do
        expect(base_10_to_base_x(23, %(abcdefghijkl))).to eq 'bl'
        expect(base_x_to_base_10('bl', %(abcdefghijkl))).to eq 23
      end
    end

    describe "the base we use" do
      it "converts from Arabic to 'our base'" do
        arabic_to_our_base = base_10_to_base_x 123, described_class::JUMBLED_ID_DIGITS
        expect(arabic_to_our_base).to eq "bZ"
      end

      it "converts from 'our base' to Arabic" do
        our_base_to_arabic = base_x_to_base_10 "bZ", described_class::JUMBLED_ID_DIGITS
        expect(our_base_to_arabic).to eq 123
      end
    end
  end

  describe ".jumble_id..." do
    it "jumbles the id..." do
      expect(described_class.send(:jumble_id, "123", 1)).to eq "Rt"
    end
  end

  describe ".unjumble_id_and_type..." do
    it "we can also unjumble the jumbled to get the id and type number..." do
      expect(described_class.send(:unjumble_id_and_type, "Rt")).to eq [123, 1]
    end
  end
end

def base_10_to_base_x number, digits
  described_class.send :base_10_to_base_x, number, digits
end

def base_x_to_base_10 number, digits
  described_class.send :base_x_to_base_10, number, digits
end
