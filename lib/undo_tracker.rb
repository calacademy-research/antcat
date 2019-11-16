class UndoTracker
  # TODO: Pass `user` from controllers.
  def self.setup_change taxon, change_type
    change = Change.create!(change_type: change_type, taxon: taxon, user: User.current)
    RequestStore.store[:current_change_id] = change.id
    change
  end

  def self.clear_change
    RequestStore.store[:current_change_id] = nil
  end

  def self.current_change_id
    RequestStore.read :current_change_id
  end
end
