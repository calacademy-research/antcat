# coding: UTF-8
require 'spec_helper'

describe GenusName do

  describe "Decomposition" do
    it "should know its genus name" do
      name = GenusName.new name: 'Atta', epithet: 'Atta'
      expect(name.genus_name).to eq('Atta')
    end
  end

end