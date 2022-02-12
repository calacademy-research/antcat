# frozen_string_literal: true

class WhatLinksHereItemDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_private_initialize :what_links_here_item

  def item_link
    case table
    when "citations"          then id
    when "history_items"      then link_to(id, history_item_path(id))
    when "protonyms"          then link_to(id, protonym_path(id))
    when "reference_sections" then link_to(id, reference_section_path(id))
    when "references"         then link_to(id, reference_path(id))
    when "taxa"               then link_to(id, catalog_path(id))
    when "type_names"         then id
    else                      raise "unknown table #{table}"
    end
  end

  def owner_link
    case owner
    when Protonym  then ("Protonym: ".html_safe << owner.decorate.link_to_protonym)
    when Reference then owner.decorate.link_to_reference
    when Taxon     then CatalogFormatter.link_to_taxon(owner)
    else           raise "unknown owner #{owner.class.name}"
    end
  end

  private

    delegate :table, :id, :owner, to: :what_links_here_item, private: true
end
