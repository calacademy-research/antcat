# coding: UTF-8
require 'spec_helper'

describe User do

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        user = FactoryGirl.create :user
        user.versions.last.event.should == 'create'
      end
    end
  end

end
