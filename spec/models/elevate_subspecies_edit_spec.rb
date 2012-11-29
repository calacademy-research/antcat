# coding: UTF-8
require 'spec_helper'

describe ElevateSubspeciesEdit do

  describe "The object" do

    it "should require the taxon and the old_species" do
      history = ElevateSubspeciesEdit.new
      history.should_not be_valid
      history.user = User.new
      history.old_species = create_species 'Formica major'
      history.should_not be_valid
      history.taxon = create_species 'Formica minor'
      history.should be_valid
    end

  end
end
