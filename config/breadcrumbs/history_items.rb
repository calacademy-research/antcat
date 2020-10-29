# frozen_string_literal: true

crumb :history_items do |protonym, protonym_fallback_link|
  link "History Items"
  parent :protonym, protonym, protonym_fallback_link
end

crumb :history_item do |history_item, protonym_fallback_link|
  if history_item.persisted?
    link "##{history_item.id}", history_item_path(history_item)
  else
    link "##{history_item.id} [deleted]"
  end
  parent :history_items, history_item.protonym, protonym_fallback_link
end

crumb :edit_history_item do |history_item|
  link "Edit"
  parent :history_item, history_item
end

crumb :history_item_history do |history_item|
  protonym_fallback_link =
    if history_item.protonym.nil?
      "[no protonym ID] (previous taxon ID: #{history_item.taxon_id || '[no ID]'})"
    end

  link "History"
  parent :history_item, history_item, protonym_fallback_link
end

crumb :new_history_item do |history_item|
  link "New"
  parent :history_items, history_item.protonym
end
