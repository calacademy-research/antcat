# coding: UTF-8
require 'spec_helper'

require 'asterisk_dagger_formatting'

describe "converting from asterisks to daggers" do
  it "should handle *" do
    '*'.convert_asterisks_to_daggers.should == '&dagger;'
  end
  it "should put the asterisk as close to the succeeding word as possible" do
    '*<b><i>atta'.convert_asterisks_to_daggers.should == '<b><i>&dagger;atta'
  end
  it "should put the asterisk as close to the succeeding word as possible" do
    '<b>*<i>atta'.convert_asterisks_to_daggers.should == '<b><i>&dagger;atta'
  end
  it "should put the asterisk as close to the succeeding word as possible" do
    '*<i>atta'.convert_asterisks_to_daggers.should == '<i>&dagger;atta'
  end
end
