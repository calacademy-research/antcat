# coding: UTF-8
require 'milieu'
module ApplicationHelper
  include LinkHelper
  include ButtonHelper

  ### authorization methods
  def user_can_edit?
    $Milieu.user_can_edit? current_user
  end
  def user_can_upload_pdfs?
    $Milieu.user_can_upload_pdfs? current_user
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
  def user_is_superadmin?
    $Milieu.user_is_superadmin? current_user
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
    mail_to 'sblum@calacademy.org', 'Feedback', subject: previewize('AntCat feedback'), body: <<-MSG.squish
      Thanks for helping us make AntCat better by replacing this message with your comments,
      suggestions, and questions. You may also want to check out the AntCat Google group at
      https://groups.google.com/forum/?fromgroups#!forum/antcat where we discuss the project.

      Stan Blum
      California Academy of Sciences
      http://antcat.org
    MSG
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

  def biogeographic_region_options_for_select value, first_label = '', second_label = nil
    value = '' unless value.present?
    string = ''.html_safe
    string << option_for_select(first_label, nil, value)
    string << option_for_select(second_label, second_label, value) if second_label.present?
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
      parent = taxon.parent
      string << parent.name.to_html
     when Subgenus
       string = "subgenus of "
       parent = taxon.parent
       string << parent.name.to_html
    when Subspecies
      string = "subspecies of "
      parent = taxon.species
      string << (parent ? parent.name.to_html : '(no species)')
    else
      ''
             end
    # Todo: Joe test this case
    if taxon[:unresolved_homonym] == true && taxon.new_record?
      string = ' secondary junior homonym of ' + string
    elsif !taxon[:collision_merge_id].nil? && taxon.new_record?
      target_taxon = Taxon.find_by_id(taxon[:collision_merge_id])
      string = ' merge back into original ' + target_taxon.name_html_cache
    end

    string = 'new ' + string if taxon.new_record?
    string.html_safe
  end

  # from formatters
  def pluralize_with_delimiters count, singular, plural = nil
    word = if count == 1
      singular
    else
      plural || singular.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

  def count_and_noun collection, noun
    quantity = collection.present? ? collection.count.to_s : 'no'
    noun << 's' unless collection.count == 1
    "#{quantity} #{noun}"
  end
end

