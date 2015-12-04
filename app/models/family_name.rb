# coding: UTF-8
class FamilyName < FamilyOrSubfamilyName
  has_paper_trail meta: {change_id: :get_current_change_id}
  include UndoTracker
end