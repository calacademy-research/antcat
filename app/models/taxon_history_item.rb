# frozen_string_literal: true

class TaxonHistoryItem < ApplicationRecord
  include Trackable

  belongs_to :taxon

  validates :taxt, presence: true
  validates :rank, inclusion: { in: Rank::TYPE_SPECIFIC_TAXON_HISTORY_ITEM_RANKS, allow_nil: true }

  before_validation :cleanup_taxts

  scope :persisted, -> { where.not(id: nil) }

  # :nocov:
  scope :vhic_unknown, -> do
    scope = self
    Taxt::HistoryItemCleanup::VIRTUAL_HISTORY_ITEM_CANDIDATES.each do |where_filter|
      scope = scope.where.not(where_filter)
    end
    scope
  end
  # :nocov:

  acts_as_list scope: :taxon
  has_paper_trail
  strip_attributes only: [:taxt, :rank], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }

  def self.search search_query, search_type
    search_type = search_type.presence || 'LIKE'

    case search_type
    when 'LIKE'
      where("taxt LIKE :q", q: "%#{search_query}%")
    when 'REGEXP'
      where("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  # Facade for future "hybrid history items".
  def to_taxt
    taxt
  end

  def ids_from_tax_tags
    taxt.scan(Taxt::TAX_OR_TAXAC_TAG_REGEX).flatten.map(&:to_i)
  end

  private

    def cleanup_taxts
      self.taxt = Taxt::Cleanup[taxt]
    end
end
