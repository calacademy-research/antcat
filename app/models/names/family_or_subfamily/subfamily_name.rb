class SubfamilyName < FamilyOrSubfamilyName
  include UndoTracker
  has_paper_trail meta: { change_id: :get_current_change_id }
end