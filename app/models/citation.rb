# This class is currently only used in `Protonym`, where the association
# is called `authorship`. I believe the plan was to use this in more places,
# say in taxt items, but that never happened. We may want to rename
# `protonyms.authorship_id` in any case.

class Citation < ApplicationRecord
  belongs_to :reference

  has_one :protonym, foreign_key: :authorship_id # See note above.

  validates :reference, presence: true

  strip_attributes only: [:notes_taxt, :pages, :forms], replace_newlines: true
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
end
