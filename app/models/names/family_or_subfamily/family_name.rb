class FamilyName < FamilyOrSubfamilyName
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
