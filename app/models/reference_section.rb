class ReferenceSection < ApplicationRecord
  include Trackable
  include PrimitiveSearch
  include RevisionsCanBeCompared

  belongs_to :taxon

  validates :taxon, presence: true

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  has_primitive_search where: ->(search_type) { <<-SQL.squish }
    title_taxt #{search_type} :q
      OR references_taxt #{search_type} :q
      OR subtitle_taxt #{search_type} :q
  SQL
  strip_attributes only: [:title_taxt, :subtitle_taxt,
    :references_taxt, :taxt], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }
end
