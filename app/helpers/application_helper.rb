# coding: UTF-8
require 'milieu'
module ApplicationHelper
  include Formatters::Formatter
  include Formatters::LinkFormatter

  ### authorization methods
  def user_can_edit_references?
    $Milieu.user_can_edit_references? current_user
  end
  def user_can_upload_pdfs?
    $Milieu.user_can_upload_pdfs? current_user
  end
  def user_can_edit_catalog?
    $Milieu.user_can_edit_catalog? current_user
  end
  def user_is_editor?
    $Milieu.user_is_editor? current_user
  end
  def user_can_approve_changes?
    $Milieu.user_can_approve_changes? current_user
  end
  def user_can_review_changes?
    $Milieu.user_can_review_changes? current_user
  end

  ###
  def make_title title
    string = ''.html_safe
    string << "#{title} - " if title
    string << $Milieu.title
    string << (Rails.env.production? ? '' : " (#{Rails.env})")
    string
  end

  def make_link_menu *items
    content_tag :span, class: 'link_menu' do |content|
      items.flatten.inject(''.html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def previewize string
    $Milieu.previewize string
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

  def milieu_indicator
    $Milieu.preview? ? (content_tag :div, 'preview', class: :preview) : ''
  end

  def rank_options_for_select value
    value = 'Species' unless value.present?
    string = ''.html_safe

    string = ''.html_safe
    string << rank_option_for_select('All', value)
    for rank in Rank.ranks
      next if rank.string.capitalize == 'Family'
      string << rank_option_for_select(rank.string, value)
      string
    end
    string
  end

  def rank_option_for_select rank_option, value
    options = {value: rank_option.capitalize}
    options[:selected] = 'selected' if rank_option.capitalize == value
    content_tag :option, rank_option.capitalize, options
  end

end

PaperTrailManager::ChangesHelper

module PaperTrailManager::ChangesHelper
  def change_item_types
    item_types = ActiveRecord::Base.connection.select_values('SELECT DISTINCT(item_type) FROM versions ORDER BY item_type')
    item_types - ['Author', 'ReferenceAuthorName']
  end
end
