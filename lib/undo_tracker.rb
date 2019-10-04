class UndoTracker
  def self.setup_change taxon, change_type, user:
    change = Change.create!(change_type: change_type, taxon: taxon, user: user)
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
