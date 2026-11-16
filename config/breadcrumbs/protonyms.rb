# frozen_string_literal: true

crumb :protonyms do
  link "Protonyms", protonyms_path
  parent :catalog
end

crumb :protonym do |protonym, fallback_link|
  if protonym.nil?
    link fallback_link
  elsif protonym.persisted?
    link protonym.name_with_fossil, protonym
  else
    link "##{protonym.id} [deleted]"
  end
  parent :protonyms
end

crumb :edit_protonym do |protonym|
  link 'Edit', edit_protonym_path(protonym)
  parent :protonym, protonym
end

crumb :protonym_history do |protonym|
  link "History"
  parent :protonym, protonym
end

crumb :protonym_notes do |protonym|
  link "Notes on this name", protonym_notes_path(protonym)
  parent :protonym, protonym
end

crumb :new_protonym_notes do |protonym|
  link "Add notes on this name"
  parent :protonym, protonym
end

crumb :edit_protonym_notes do |protonym|
  link "Edit"
  parent :protonym_notes, protonym
end

# By the page of notes (a history is found by its record's id); a deleted page still shows its history.
crumb :notes_page_history do |notes_page|
  link "History"
  protonym = Protonym.find_by(id: notes_page.protonym_id)
  if protonym && NotesPage.exists?(notes_page.id)
    parent :protonym_notes, protonym
  elsif protonym
    parent :protonym, protonym
  else
    parent :protonyms
  end
end

crumb :protonym_what_links_here do |protonym|
  link "What Links Here"
  parent :protonym, protonym
end

crumb :new_protonym do
  link "New"
  parent :protonyms
end

crumb :protonym_soft_validations do |protonym|
  link "Soft validations"
  parent :protonym, protonym
end

crumb :move_protonym_items do |protonym|
  link "Move items", new_protonym_move_items_path(protonym)
  parent :protonym, protonym
end

crumb :move_protonym_items_select_target do |protonym|
  link "Select target"
  parent :move_protonym_items, protonym
end

crumb :move_protonym_items_to do |protonym, to_protonym|
  link "to #{to_protonym.name_with_fossil}".html_safe,
    protonym_move_items_path(protonym, to_protonym_id: to_protonym.id)
  parent :move_protonym_items, protonym
end

crumb :reorder_history_items do |protonym|
  link "Reorder history items", protonym_reorder_history_items_path(protonym)
  parent :protonym, protonym
end
