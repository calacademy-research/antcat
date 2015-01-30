# coding: UTF-8
require 'spec_helper'

describe Reference do
  before do
    @reference = FactoryGirl.create :article_reference
  end

  it "should start as 'none'" do
    expect(@reference).to be_none
    expect(@reference.can_start_reviewing?).to be_truthy
    expect(@reference.can_finish_reviewing?).to be_falsey
    expect(@reference.can_restart_reviewing?).to be_falsey
  end

  it "none transitions to start" do
    @reference.start_reviewing!
    expect(@reference).to be_reviewing
    expect(@reference.can_start_reviewing?).to be_falsey
    expect(@reference.can_finish_reviewing?).to be_truthy
    expect(@reference.can_restart_reviewing?).to be_falsey
  end

  it "start transitions to finish" do
    @reference.start_reviewing!
    @reference.finish_reviewing!
    expect(@reference).not_to be_reviewing
    expect(@reference).to be_reviewed
    expect(@reference.can_start_reviewing?).to be_falsey
    expect(@reference.can_finish_reviewing?).to be_falsey
    expect(@reference.can_restart_reviewing?).to be_truthy
  end

  it "reviewed can transition back to reviewing" do
    @reference.start_reviewing!
    @reference.finish_reviewing!
    @reference.restart_reviewing!
    expect(@reference).to be_reviewing
    expect(@reference.can_start_reviewing?).to be_falsey
    expect(@reference.can_finish_reviewing?).to be_truthy
    expect(@reference.can_restart_reviewing?).to be_falsey
  end

end
