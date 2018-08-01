# TODO fix this issue in the database.
# All protonyms have authorships: # `Protonym.where(authorship: nil).count` # 0
# New protonyms cannot be created without a reference,
# but there are 16 of them in the db.
#
# Protonym.count                                         # 24512
# joined = Protonym.joins(authorship: :reference)
# joined.where("references.year IS NOT NULL").count      # 24496
# joined.where("references.year IS NULL").count          # 16
#
# See `ProtonymsWithReferencesMissingYear` for a database script for finding these.

class Protonym < ApplicationRecord
  # TODO we cannot do `dependent: :destroy` because there are protonyms that share the
  # same `authorship_id`. We may not want to allow sharing `authorship_id`.
  # See `Protonym.group(:authorship_id).having("COUNT(*) > 1").count.count`
  belongs_to :authorship, class_name: 'Citation'
  belongs_to :name

  has_one :taxon

  validates :authorship, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:locality], replace_newlines: true
end
