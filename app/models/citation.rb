# This class is currently only used in `Protonym`, where the association
# is called `authorship`. I believe the plan was to use this in more places,
# say in taxt items, but that never happened. We may want to rename
# `protonyms.authorship_id` in any case.

class Citation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  belongs_to :reference

  validates :reference, presence: true

  before_save { CleanNewlines.clean_newlines self, :notes_taxt }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
