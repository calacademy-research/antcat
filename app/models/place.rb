class Place < ActiveRecord::Base
  include UndoTracker

  validates_presence_of :name
  has_paper_trail meta: { change_id: :get_current_change_id }

end
