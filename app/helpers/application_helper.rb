# coding: UTF-8
module ApplicationHelper

  def user_is_editor?
    user_signed_in?
  end

  def user_can_edit?
    $ReleaseType.user_can_edit? current_user
  end

  def user_can_not_edit?
    ReleaseType.user_can_not_edit?
  end

  def make_link_menu *items
    content_tag :span, class: 'link_menu' do |content|
      items.flatten.inject("".html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def feedback_link
    mail_to 'mark@mwilden.com', 'Feedback', target: '_blank', subject: 'AntCat feedback', body: <<-EOS
Thanks for helping us make AntCat better by replacing this message with your comments, suggestions, and questions. You may also want to check out the AntCat Google group at https://groups.google.com/forum/?fromgroups#!forum/antcat where we discuss the project.

Mark Wilden
Web Applications Developer
California Academy of Sciences
http://antcat.org
      EOS
  end

end
