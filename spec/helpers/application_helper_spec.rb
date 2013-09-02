# coding: UTF-8
require 'spec_helper'

describe ApplicationHelper do

  describe 'Making a link menu' do
    it "should put bars between them and be html safe" do
      result = helper.make_link_menu(['a', 'b'])
      result.should == '<span class="link_menu">a | b</span>'
    end
    it "should always be html safe" do
      helper.make_link_menu('a'.html_safe, 'b'.html_safe).should be_html_safe
      helper.make_link_menu(['a'.html_safe, 'b']).should be_html_safe
    end
  end

  describe "Authorization" do
    before do
      @current_user = double
      helper.stub(:current_user).and_return @current_user
    end

    specify "reference editing authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_edit_references?).with @current_user
      helper.user_can_edit_references?
    end

    specify "catalog editing authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_edit_catalog?).with @current_user
      helper.user_can_edit_catalog?
    end

    specify "editing authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_edit_catalog?).with @current_user
      helper.user_can_edit_catalog?
    end

    specify "updloading PDF authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_edit_catalog?).with @current_user
      helper.user_can_edit_catalog?
    end

    specify "reviewing changes authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_review_changes?).with @current_user
      helper.user_can_review_changes?
    end

    specify "approving changes authorization depends on the milieu and current user" do
      $Milieu.should_receive(:user_can_approve_changes?).with @current_user
      helper.user_can_approve_changes?
    end

  end

  describe "Formatting time ago" do
    it "should call Formatters::Formatter" do
      time = Time.now - 1.hour
      helper.format_time_ago(time).should =~ %r{<span title=[^>]+>about 1 hour ago</span>}
    end
  end

  describe "Converting a hash to a parameter string" do
    it "should work" do
      helper.hash_to_params_string(a: 'b').should == 'a="b"'
    end
  end

end
