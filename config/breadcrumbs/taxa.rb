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
  link "Edit"
  parent :taxon_being_edited, taxon
end
