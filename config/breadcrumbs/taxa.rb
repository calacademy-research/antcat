# frozen_string_literal: true

crumb :edit_catalog do
  link "Edit Catalog"
end

crumb :new_taxon do |parent_id, rank_to_create|
  link "Add #{rank_to_create.downcase}"
  parent Taxon.find(parent_id)
end

crumb :edit_taxon do |taxon|
  if taxon
    link "Edit", edit_taxa_path(taxon)
    parent taxon
  else
    link "[deleted]"
    parent :edit_catalog
  end
end

crumb :convert_species_to_subspecies do |taxon|
  link "Convert species to subspecies"
  parent :edit_taxon, taxon
end

crumb :create_combination do |taxon|
  link "Create combination"
  parent :edit_taxon, taxon
end

crumb :create_combination_help do |taxon|
  link "Create combination help"
  parent :edit_taxon, taxon
end

crumb :create_obsolete_combination do |taxon|
  link "Create obsolete combination"
  parent :edit_taxon, taxon
end

crumb :force_parent_change do |taxon|
  link "Force parent change"
  parent :edit_taxon, taxon
end

crumb :move_items do |taxon|
  link "Move items", new_taxa_move_items_path(taxon)
  parent :edit_taxon, taxon
end

crumb :move_items_select_target do |taxon|
  link "Select target"
  parent :move_items, taxon
end

crumb :move_items_to do |taxon, to_taxon|
  link "to #{to_taxon.name_with_fossil}".html_safe, taxa_move_items_path(taxon, to_taxon_id: to_taxon.id)
  parent :move_items, taxon
end
