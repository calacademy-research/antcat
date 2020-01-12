# rubocop:disable Layout/IndentationConsistency
crumb :taxon_history_items do |taxon|
  link "History Items"
  parent taxon
end

  crumb :taxon_history_item do |taxon_history_item|
    if taxon_history_item.persisted?
      link "##{taxon_history_item.id}", taxon_history_item
    else
      link "##{taxon_history_item.id} [deleted]"
    end
    parent :taxon_history_items, taxon_history_item.taxon
  end

    crumb :edit_taxon_history_item do |taxon_history_item|
      link "Edit"
      parent :taxon_history_item, taxon_history_item
    end

    crumb :taxon_history_item_history do |taxon_history_item|
      link "History"
      parent :taxon_history_item, taxon_history_item
    end

  crumb :new_taxon_history_item do |taxon_history_item|
    link "New"
    parent :taxon_history_items, taxon_history_item.taxon
  end
# rubocop:enable Layout/IndentationConsistency
