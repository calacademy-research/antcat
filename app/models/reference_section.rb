class ReferenceSection < ApplicationRecord
  include Trackable
  include RevisionsCanBeCompared

  belongs_to :taxon

  validates :taxon, presence: true

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }
  strip_attributes only: [:title_taxt, :subtitle_taxt, :references_taxt], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }

  def self.search(search_query, search_type)
    search_type = search_type.presence || 'LIKE'
    raise unless search_type.in? ["LIKE", "REGEXP"]

    q = if search_type == "LIKE"
          "%#{search_query}%"
        else
          search_query
        end

    where(<<-SQL.squish, q: q)
      title_taxt #{search_type} :q
        OR references_taxt #{search_type} :q
        OR subtitle_taxt #{search_type} :q
    SQL
  end
end
