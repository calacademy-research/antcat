# coding: UTF-8
require 'spec_helper'

describe ForwardRefFromTaxt do

  it "needs a name" do
    ForwardRefFromTaxt.new.should_not be_valid
    ForwardRefFromTaxt.new(name: create_name('Atta')).should be_valid
  end

end
