class TaxonHistoryItem < ApplicationRecord
  include Trackable
  include PrimitiveSearch
  include RevisionsCanBeCompared

  belongs_to :taxon

  validates :taxt, :taxon, presence: true

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }
  has_primitive_search where: ->(search_type) { "taxt #{search_type} :q" }
  strip_attributes only: [:taxt], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }
end
