# coding: UTF-8
module ApplicationHelper
  require 'environment'
  def user_can_edit_references?
    $Environment.user_can_edit_references? current_user
  end
  def user_can_edit_catalog?
    $Environment.user_can_edit_catalog? current_user
  end
  def user_is_editor?
    $Environment.user_is_editor? current_user
  end

  def make_title title
    string = ''.html_safe
    string << "#{title} - " if title
    string << $Environment.title
    string << (Rails.env.production? ? '' : " (#{Rails.env})")
    string
  end

  def make_link_menu *items
    content_tag :span, class: 'link_menu' do |content|
      items.flatten.inject("".html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def previewize string
    $Environment.previewize string
  end

  def feedback_link
    mail_to 'mark@mwilden.com', 'Feedback', target: '_blank', subject: previewize('AntCat feedback'), body: <<-EOS
Thanks for helping us make AntCat better by replacing this message with your comments, suggestions, and questions. You may also want to check out the AntCat Google group at https://groups.google.com/forum/?fromgroups#!forum/antcat where we discuss the project.

Mark Wilden
Web Applications Developer
California Academy of Sciences
http://antcat.org
      EOS
  end

  def environment_indicator
    $Environment.preview? ? (content_tag :div, 'preview', class: :preview) : ''
  end

  def add_period_if_necessary string
    Formatters::Formatter.add_period_if_necessary string
  end

end
