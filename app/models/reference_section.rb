# frozen_string_literal: true

class ReferenceSection < ApplicationRecord
  include Trackable

  TAXON_TYPES_WITH_REFERENCE_SECTIONS = %w[Family Subfamily Tribe Subtribe Genus Subgenus]

  belongs_to :taxon

  before_validation :cleanup_taxts

  acts_as_list scope: :taxon
  has_paper_trail
  strip_attributes only: [:title_taxt, :subtitle_taxt, :references_taxt], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }

  def self.search search_query, search_type
    search_type = search_type.presence || 'LIKE'
    raise unless search_type.in? ["LIKE", "REGEXP"]

    q = search_type == "LIKE" ? "%#{search_query}%" : search_query
    where(<<-SQL.squish, q: q)
      title_taxt #{search_type} :q
        OR references_taxt #{search_type} :q
        OR subtitle_taxt #{search_type} :q
    SQL
  end

  private

    def cleanup_taxts
      self.references_taxt = Taxt::Cleanup[references_taxt]
      self.subtitle_taxt = Taxt::Cleanup[subtitle_taxt]
      self.title_taxt = Taxt::Cleanup[title_taxt]
    end
end
