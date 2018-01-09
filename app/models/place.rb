class Place < ApplicationRecord
  validates_presence_of :name

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
