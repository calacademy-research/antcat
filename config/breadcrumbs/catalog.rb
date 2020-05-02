# frozen_string_literal: true

crumb :catalog do
  link "Catalog", root_path
end

crumb :family do |_taxon|
  taxon = Family.first
  link taxon.name_with_fossil, catalog_path(taxon)
  parent :catalog
end

[:subfamily, :tribe, :subtribe, :genus, :subgenus, :species, :subspecies, :infrasubspecies].each do |rank|
  crumb rank do |taxon|
    if taxon.name
      link taxon.name_with_fossil, catalog_path(taxon)
    else
      link '[deleted name]'
    end

    if (taxon_parent = taxon.parent)
      parent_as_symbol = taxon_parent.class.name.downcase.to_sym
      parent parent_as_symbol, taxon_parent
    end
  end
end

crumb :taxon_history do |taxon|
  link "History"
  parent taxon
end

crumb :taxon_what_links_here do |taxon|
  link "What Links Here"
  parent taxon
end

crumb :taxon_show_children do |taxon|
  link "Show Children"
  parent taxon
end

crumb :taxon_soft_validations do |taxon|
  link "Soft validations"
  parent taxon
end

crumb :bolton_view do |taxon|
  link "Bolton view ".html_safe + beta_label
  parent taxon
end

crumb :wikipedia_tools do |taxon|
  link "Wikipedia tools"
  parent taxon
end

crumb :catalog_search do
  link "Search"
  parent :catalog
end
