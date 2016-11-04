require 'paper_trail'

module UndoTracker
  # TODO associate the change with the current_user instead of getting that
  # from the versions. `User.current` *may* be useful for this.
  # TODO maybe rename -- this *creates* the change.
  def setup_change taxon, change_type
    change = Change.new
    change.change_type = change_type
    change.user_changed_taxon_id = taxon.id
    change.save!
    RequestStore.store[:current_change_id] = change.id
    change
  end

  def clear_change
    RequestStore.store[:current_change_id] = nil
  end

  # Move to Change?
  def get_current_change_id
    RequestStore.read :current_change_id
  end
end
