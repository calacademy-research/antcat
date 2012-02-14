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

end
