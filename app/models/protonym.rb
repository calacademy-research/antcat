class Protonym < ApplicationRecord
  # TODO we cannot do `dependent: :destroy` because there are protonyms that share the
  # same `authorship_id`. We may not want to allow sharing `authorship_id`.
  # See `Protonym.group(:authorship_id).having("COUNT(*) > 1").count.count`
  belongs_to :authorship, class_name: 'Citation'
  belongs_to :name

  has_many :taxa, class_name: 'Taxon'

  validates :authorship, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:locality], replace_newlines: true
end
