# rubocop:disable Layout/IndentationConsistency
crumb :catalog do
  link "Catalog", root_path
end

  crumb :family do |_taxon|
    link Family.first.link_to_taxon
    parent :catalog
  end

  ranks = [:subfamily, :tribe, :subtribe, :genus, :subgenus, :species, :subspecies]
  ranks.each do |rank|
    crumb rank do |taxon|
      if taxon.name
        link taxon.link_to_taxon
      else
        link '[deleted name]'
      end
      parent_as_symbol = taxon.parent.class.name.downcase.to_sym
      parent parent_as_symbol, taxon.parent rescue :family
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

  crumb :wikipedia_tools do |taxon|
    link "Wikipedia tools"
    parent taxon
  end

crumb :catalog_search do
  link "Search"
  parent :catalog
end
# rubocop:enable Layout/IndentationConsistency
