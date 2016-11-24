class Citation < ActiveRecord::Base
  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  belongs_to :reference

  validates :reference, presence: true

  before_save { CleanNewlines.clean_newlines self, :notes_taxt }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
