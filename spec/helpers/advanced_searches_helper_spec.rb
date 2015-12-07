require 'spec_helper'

describe AdvancedSearchesHelper do
  describe "Converting a hash to a parameter string" do
    it "should work" do
      expect(helper.hash_to_params_string(a: 'b', c: 'd')).to eq 'a=b&c=d'
    end
  end
end