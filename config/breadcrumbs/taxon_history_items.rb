# frozen_string_literal: true

crumb :taxon_history_items do |protonym, protonym_fallback_link|
  link "History Items"
  parent :protonym, protonym, protonym_fallback_link
end

crumb :taxon_history_item do |taxon_history_item, protonym_fallback_link|
  if taxon_history_item.persisted?
    link "##{taxon_history_item.id}", taxon_history_item_path(taxon_history_item)
  else
    link "##{taxon_history_item.id} [deleted]"
  end
  parent :taxon_history_items, taxon_history_item.protonym, protonym_fallback_link
end

crumb :edit_taxon_history_item do |taxon_history_item|
  link "Edit"
  parent :taxon_history_item, taxon_history_item
end

crumb :taxon_history_item_history do |taxon_history_item|
  protonym_fallback_link =
    if taxon_history_item.protonym.nil?
      "[no protonym ID] (previous taxon ID: #{taxon_history_item.taxon_id || '[no ID]'})"
    end

  link "History"
  parent :taxon_history_item, taxon_history_item, protonym_fallback_link
end

crumb :new_taxon_history_item do |taxon_history_item|
  link "New"
  parent :taxon_history_items, taxon_history_item.protonym
end
