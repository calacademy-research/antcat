class UndoTracker
  # TODO: Maybe rename -- this *creates* the change.
  # TODO: Pass `user` from controllers.
  def self.setup_change taxon, change_type
    change = Change.create! change_type: change_type, taxon: taxon, user: User.current
    RequestStore.store[:current_change_id] = change.id
    change
  end

  # Maybe https://github.com/calacademy-research/antcat/issues/164 is related to not
  # clearing the RequestStore? `:current_change_id` is only cleared in `Change#undo`,
  # which is why versions of models such as `Feedback` and `Issue` may have
  # `change_id`s (they should not).
  def self.clear_change
    RequestStore.store[:current_change_id] = nil
  end

  def self.get_current_change_id
    RequestStore.read :current_change_id
  end
end
