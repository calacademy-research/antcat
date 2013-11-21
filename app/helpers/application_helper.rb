# coding: UTF-8
require 'milieu'
module ApplicationHelper
  include Formatters::Formatter
  include Formatters::LinkFormatter
  include Formatters::ButtonFormatter

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
    value = 'All' unless value.present?
    string = ''.html_safe

    string = ''.html_safe
    string << option_for_select('All', 'All', value)
    for rank in Rank.ranks
      next if rank.plural.capitalize == 'Families'
      string << option_for_select(rank.plural.capitalize, rank.string.capitalize, value)
      string
    end
    string
  end

  def biogeographic_region_options_for_select value
    value = '' unless value.present?
    string = ''.html_safe
    string << option_for_select('', nil, value)
    for biogeographic_region in BiogeographicRegion.instances
      string << option_for_select(biogeographic_region.label, biogeographic_region.value, value)
      string
    end
    string
  end

  def option_for_select label, value, current_value
    options = {value: value}
    options[:selected] = 'selected' if value == current_value
    content_tag :option, label, options
  end

  def search_selector search_type
    select_tag :st, options_for_select([['matching', 'm'], ['beginning with', 'bw'], ['containing', 'c']], search_type || 'bw')
  end

  def name_description taxon
    string = case taxon
    when Subfamily
      'subfamily'
    when Tribe
      string = "tribe of "
      parent = taxon.subfamily
      string << (parent ? parent.name.to_html : '(no subfamily)')
    when Genus
      string = "genus of "
      parent = taxon.tribe ? taxon.tribe : taxon.subfamily
      string << (parent ? parent.name.to_html : '(no subfamily)')
    when Species
      string = "species of "
      parent = taxon.genus
      string << parent.name.to_html
    when Subspecies
      string = "subspecies of "
      parent = taxon.species
      string << (parent ? parent.name.to_html : '(no species)')
    else
      ''
    end
    string = 'new ' + string if taxon.new_record?
    string.html_safe
  end

end

PaperTrailManager::ChangesHelper

module PaperTrailManager::ChangesHelper
  def change_item_types
    item_types = ActiveRecord::Base.connection.select_values('SELECT DISTINCT(item_type) FROM versions ORDER BY item_type')
    item_types - ['Author', 'ReferenceAuthorName']
  end
end
