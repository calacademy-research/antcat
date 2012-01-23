# coding: UTF-8
require 'spec_helper'

describe Vlad do
  it "should idate" do
    Vlad.idate
  end

  it "should show genera with tribes but not subfamilies" do
    tribe = Factory :tribe
    genus_with_tribe_but_not_subfamily = Factory :genus, subfamily: nil, tribe: tribe
    genus_with_tribe_and_subfamily = Factory :genus, subfamily: tribe.subfamily, tribe: tribe
    genus_with_subfamily_but_not_tribe = Factory :genus, subfamily: tribe.subfamily, tribe: nil
    results = Vlad.idate[:genera_with_tribes_but_not_subfamilies]
    results.count.should == 1
    results.first.should == genus_with_tribe_but_not_subfamily
  end
end
