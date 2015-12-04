# coding: UTF-8
class SubfamilyName < FamilyOrSubfamilyName
  has_paper_trail meta: {change_id: :get_current_change_id}
  include UndoTracker
end