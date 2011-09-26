# coding: UTF-8
require 'spec_helper'

require 'asterisk_dagger_formatting'

describe "converting from asterisks to daggers" do
  it "should handle *" do
    input = '*'
    input.convert_asterisks_to_daggers!.should == '&dagger;'
    input.should == '&dagger;'
  end
  it "should put the asterisk as close to the succeeding word as possible" do
    input           = '*<b><i>atta'
    expected_output = '<b><i>&dagger;atta'
    input.convert_asterisks_to_daggers!.should == expected_output
    input.should == expected_output
  end
  it "should put the asterisk as close to the succeeding word as possible" do
    input           = '<b>*<i>atta'
    expected_output = '<b><i>&dagger;atta'
    input.convert_asterisks_to_daggers!.should == expected_output
    input.should == expected_output
  end
end
