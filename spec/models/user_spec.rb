# coding: UTF-8
require 'spec_helper'
describe User do

  specify "A user is an editor" do
    User.new.is_editor?.should be_true
  end

  it "knows whether it can edit the catalog" do
    User.new.can_edit_catalog.should be_false
    User.new(can_edit_catalog: true).can_edit_catalog.should be_true
  end

  it "knows whether it can review changes" do
    User.new.can_review_changes?.should be_false
    User.new(can_edit_catalog: true).can_review_changes?.should be_true
  end

  it "knows whether it can approve changes" do
    User.new.can_approve_changes.should be_false
    User.new(can_approve_changes: true).can_approve_changes.should be_true
  end

end
