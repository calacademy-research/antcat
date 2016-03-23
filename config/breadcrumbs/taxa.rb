crumb :edit_catalog do
  link "Edit Catalog"
end

crumb :new_taxon do
  link "Add Taxon"
  parent :edit_catalog
end

crumb :taxon_being_edited do |taxon|
  link "#{taxon.name.epithet} (##{taxon.id})", catalog_path(taxon)
  parent :edit_catalog
end

crumb :edit_taxon do |taxon|
  link "Edit", edit_taxa_path(taxon)
  parent :taxon_being_edited, taxon
end

crumb :convert_to_species do |taxon|
  link "Convert to Species"
  parent :edit_taxon, taxon
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
