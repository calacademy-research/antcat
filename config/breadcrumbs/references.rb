# frozen_string_literal: true

crumb :references do
  link "References", references_path
end

crumb :reference do |reference|
  if reference.persisted?
    link sanitize(reference.key_with_suffixed_year), reference_path(reference)
  else
    link "##{reference.id} [deleted]"
  end
  parent :references
end

crumb :edit_reference do |reference|
  link "Edit"
  parent :reference, reference
end

crumb :reference_history do |reference|
  link "History"
  parent :reference, reference
end

crumb :reference_what_links_here do |reference|
  link "What Links Here"
  parent :reference, reference
end

crumb :new_reference do
  link "New"
  parent :references
end

crumb :references_search_results do
  link "Search Results"
  parent :references
end

crumb :references_search_help do
  link "Search Help"
  parent :references
end

crumb :all_references do
  link "All References", references_path
  parent :references
end

crumb :references_latest_additions do
  link "Latest Additions", references_latest_additions_path
  parent :references
end

crumb :references_latest_changes do
  link "Latest Changes", references_latest_changes_path
  parent :references
end
