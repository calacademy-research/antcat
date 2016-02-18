crumb :catalog do
 link "Catalog", root_path
end

  crumb :family do |taxon|
    link taxon_breadcrumb_link(Family.first)
    parent :catalog
  end

  ranks = [:subfamily, :tribe, :subtribe, :genus, :subgenus, :species, :subspecies]
  ranks.each do |rank|
    crumb rank do |taxon|
      link taxon_breadcrumb_link(taxon)
      parent_as_symbol = taxon.parent.class.name.downcase.to_sym
      parent parent_as_symbol, taxon.parent
    end
  end

crumb :catalog_search do
  link "Search"
  parent :catalog
end

crumb :catalog_advanced_search do
  link "Advanced Search"
  parent :catalog
end
