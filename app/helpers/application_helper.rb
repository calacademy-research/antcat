# coding: UTF-8
module ApplicationHelper

  def make_link_menu *items
    content_tag :span, class: 'link_menu' do |content|
      items.flatten.inject("".html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def feedback_link
    mail_to 'mark@mwilden.com', 'Feedback', target: '_blank', subject: 'AntCat feedback'
  end

end
