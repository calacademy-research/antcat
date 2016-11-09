# TODO `year´:
#   1) find proper name to use in `ReferenceDecorator`, 2) consider moving
#   all/some of them to `Reference`, 3) give methods here matching names.
#
# Note on the nil checks: tests pass without them, but the AntWeb
#   exporter spec raises in `#year`, but recovers from it.
#
#   All protonyms have authorships: # `Protonym.where(authorship: nil).count` # 0
#   New protonyms cannot be created without a reference,
#   but there are 16 of them in the db.
#   ```
#   Protonym.count                                         # 24512
#   joined = Protonym.joins(authorship: :reference)
#   joined.where("references.year IS NOT NULL").count      # 24496
#   joined.where("references.year IS NULL").count          # 16
#   ```
#
#   TODO fix this issue in the database.

class Citation < ActiveRecord::Base
  include UndoTracker

  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  belongs_to :reference

  validates :reference, presence: true

  before_save { CleanNewlines.clean_newlines self, :notes_taxt }

  has_paper_trail meta: { change_id: :get_current_change_id }

  def year
    return unless reference
    reference.decorate.year_or_no_year
  end
end
