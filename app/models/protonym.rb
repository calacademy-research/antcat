class Protonym < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  belongs_to :authorship, class_name: 'Citation', dependent: :destroy
  belongs_to :name

  has_many :taxa, class_name: 'Taxon'

  validates :authorship, presence: true
  validates :name, presence: true

  scope :order_by_name, -> { joins(:name).order('names.name') }

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:locality], replace_newlines: true
  trackable parameters: proc { { name: decorate.format_name } }
end
