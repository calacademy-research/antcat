# frozen_string_literal: true

class RevisionHistoryPath
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include Service

  attr_private_initialize :type, :id

  def call
    url
  end

  private

    def url
      case type
      when "HistoryItem"      then history_item_history_path id
      when "Institution"      then institution_history_path id
      when "Issue"            then issue_history_path id
      when "Name"             then name_history_path id
      when "Protonym"         then protonym_history_path id
      when "Reference"        then reference_history_path id
      when "ReferenceSection" then reference_section_history_path id
      when "Taxon"            then taxon_history_path id
      when "Tooltip"          then tooltip_history_path id
      when "WikiPage"         then wiki_page_history_path id
      end
    end
end
