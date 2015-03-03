module UndoTracker

  def setup_change change_type
    change = Change.new
    change.change_type = change_type
    change.user_changed_taxon_id = @taxon.id
    change.save!
    RequestStore.store[:current_change_id] = change.id
    change
  end

  def link_change_id
    current_change_id = RequestStore.store[:current_change_id]
    most_recent_version_id = versions(true).last

    transaction = Transaction.new
    transaction.paper_trail_version = most_recent_version_id
    transaction.change_id = current_change_id
    transaction.save!
    RequestStore.store[:last_version_id] = transaction.paper_trail_version

    puts("\nJoe: for taxa id: "+
             id.to_s+" Creating new transaction with id: + " +
             transaction.id.to_s +
             " change id: " +
             current_change_id.to_s +
             " paper trail id: " +
             transaction.paper_trail_version.id.to_s +
             "\n")
  end

end