# coding: UTF-8
module ApplicationHelper
  require 'release_type'

  def preview?
    $ReleaseType.preview?
  end

  def user_is_editor?
    user_signed_in?
  end

  def user_can_edit?
    $ReleaseType.user_can_edit? current_user
  end

  def user_can_not_edit?
    !user_can_edit?
  end

  def make_title title
    string = ''.html_safe
    string << "#{title} - " if title
    string << $ReleaseType.title
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
    return string + ' (preview)' if preview?
    string
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

  def release_type_indicator
    $ReleaseType.preview? ? (content_tag :div, 'preview', class: :preview) : ''
  end

  def add_period_if_necessary string
    Formatters::Formatter.add_period_if_necessary string
  end

end
