# rubocop:disable Layout/IndentationConsistency
crumb :catalog do
  link "Catalog", root_path
end

  crumb :family do |_taxon|
    link Family.first.link_to_taxon
    parent :catalog
  end

  [:subfamily, :tribe, :subtribe, :genus, :subgenus, :species, :subspecies, :infrasubspecies].each do |rank|
    crumb rank do |taxon|
      if taxon.name
        link taxon.link_to_taxon
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

  crumb :taxon_soft_validations do |taxon|
    link "Soft validations"
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
# rubocop:enable Layout/IndentationConsistency
