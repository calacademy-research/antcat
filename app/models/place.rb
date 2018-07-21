class Place < ApplicationRecord
  validates :name, presence: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
