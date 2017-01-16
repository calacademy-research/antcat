class ReferenceAuthorName < ActiveRecord::Base
  belongs_to :reference
  belongs_to :author_name

  acts_as_list scope: :reference
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
