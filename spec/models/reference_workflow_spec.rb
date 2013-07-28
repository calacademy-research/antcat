# coding: UTF-8
require 'spec_helper'

describe Reference do
  before do
    @reference = FactoryGirl.create :article_reference
  end

  it "should start as 'none'" do
    @reference.should be_none
    @reference.can_start_reviewing?.should be_true
    @reference.can_finish_reviewing?.should be_false
    @reference.can_restart_reviewing?.should be_false
  end

  it "none transitions to start" do
    @reference.start_reviewing!
    @reference.should be_reviewing
    @reference.can_start_reviewing?.should be_false
    @reference.can_finish_reviewing?.should be_true
    @reference.can_restart_reviewing?.should be_false
  end

  it "start transitions to finish" do
    @reference.start_reviewing!
    @reference.finish_reviewing!
    @reference.should_not be_reviewing
    @reference.should be_reviewed
    @reference.can_start_reviewing?.should be_false
    @reference.can_finish_reviewing?.should be_false
    @reference.can_restart_reviewing?.should be_true
  end

  it "reviewed can transition back to reviewing" do
    @reference.start_reviewing!
    @reference.finish_reviewing!
    @reference.restart_reviewing!
    @reference.should be_reviewing
    @reference.can_start_reviewing?.should be_false
    @reference.can_finish_reviewing?.should be_true
    @reference.can_restart_reviewing?.should be_false
  end

end
