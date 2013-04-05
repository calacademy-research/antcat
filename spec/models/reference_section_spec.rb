# coding: UTF-8
require 'spec_helper'

describe ReferenceSection do

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        reference_section = FactoryGirl.create :reference_section
        reference_section.versions.last.event.should == 'create'
      end
    end
  end

end

