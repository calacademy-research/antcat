# rubocop:disable Layout/IndentationConsistency
crumb :catalog do
  link "Catalog", root_path
end

  crumb :family do |_taxon|
    link taxon_breadcrumb_link(Family.first)
    parent :catalog
  end

  ranks = [:subfamily, :tribe, :genus, :subgenus, :species, :subspecies]
  ranks.each do |rank|
    crumb rank do |taxon|
      link taxon_breadcrumb_link(taxon)
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

crumb :protonyms do
  link "Protonyms", protonyms_path
  parent :catalog
end

  crumb :protonym do |protonym|
    link protonym.decorate.format_name, protonym_path(protonym)
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
# rubocop:enable Layout/IndentationConsistency
