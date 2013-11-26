# coding: UTF-8
require 'spec_helper'
describe User do

  specify "A user is not necessarily an editor" do
    User.new.is_editor?.should_not be_true
  end

  it "knows whether it can edit the catalog" do
    User.new.can_edit.should be_false
    User.new(can_edit: true).can_edit.should be_true
  end

  it "knows whether it can review changes" do
    User.new.can_review_changes?.should be_false
    User.new(can_edit: true).can_review_changes?.should be_true
  end

  it "knows whether it can approve changes" do
    User.new.can_approve_changes?.should be_false
    User.new(can_edit: true).can_approve_changes?.should be_true
  end

end
