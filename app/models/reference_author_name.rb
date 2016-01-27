class ReferenceAuthorName < ActiveRecord::Base
  include UndoTracker

  belongs_to :reference
  belongs_to :author_name
  acts_as_list :scope => :reference
  has_paper_trail meta: { change_id: :get_current_change_id }
end
