crumb :edit_catalog do
  link "Edit Catalog"
end

crumb :new_taxon do
  link "Add Taxon"
  parent :edit_catalog
end

crumb :taxon_being_edited do |taxon|
  if taxon
    link "#{taxon.name_html_cache} (##{taxon.id})".html_safe, catalog_path(taxon)
  else
    link "[deleted]"
  end
  parent :edit_catalog
end

crumb :edit_taxon do |taxon|
  link "Edit", edit_taxa_path(taxon)
  parent :taxon_being_edited, taxon
end

  crumb :edit_taxon_show_children do |taxon|
    link "Show Children"
    parent :edit_taxon, taxon
  end

  crumb :confirm_before_delete_taxon do |taxon|
    link "Confirm before delete taxon (superadmin)"
    parent :edit_taxon, taxon
  end

crumb :convert_to_species do |taxon|
  link "Convert to Species"
  parent :edit_taxon, taxon
end

crumb :taxon_history_items do
  link "Taxon History Items"
  parent :catalog
end

crumb :reference_sections do
  link "Reference Sections"
  parent :catalog
end

# Crumbs for the shallow routes for the feed
crumb :taxon_history_item do |item|
  link "History Item ##{item.id}"
  parent :taxon_being_edited, item.taxon
end

crumb :reference_section do |item|
  link "Reference Section ##{item.id}"
  parent :taxon_being_edited, item.taxon
end

crumb :synonym_relationship do |synonym|
  link "Synonym Relationship ##{synonym.id}"
  parent :edit_catalog
end
