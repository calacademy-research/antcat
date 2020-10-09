# frozen_string_literal: true

class TaxonHistoryItem < ApplicationRecord
  include Trackable

  # TODO: Remove `belongs_to :taxon` and change to `belongs_to :protonym, optional: false`. [grep:proitem]
  belongs_to :taxon, optional: true
  belongs_to :protonym, optional: true

  has_one :terminal_taxon, through: :protonym
  has_many :terminal_taxa, through: :protonym

  validates :protonym, presence: true, on: :create # TODO: [grep:proitem].
  validates :taxt, presence: true
  validates :rank, inclusion: { in: Rank::AntCatSpecific::TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES, allow_nil: true }

  before_validation :cleanup_taxts

  scope :persisted, -> { where.not(id: nil) }
  scope :unranked_and_for_rank, ->(type) { where(rank: [nil, type]) }

  acts_as_list scope: :protonym
  has_paper_trail
  strip_attributes only: [:taxt, :rank], replace_newlines: true
  trackable parameters: proc { { protonym_id: protonym_id } }

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

  # TODO: Copy-pasta quick fix.
  def self.exclude_search search_query, search_type
    search_type = search_type.presence || 'LIKE'

    case search_type
    when 'LIKE'
      where.not("taxt LIKE :q", q: "%#{search_query}%")
    when 'REGEXP'
      where.not("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  # Facade for future "hybrid history items".
  def to_taxt
    taxt
  end

  def ids_from_tax_or_taxac_tags
    Taxt.extract_ids_from_tax_or_taxac_tags taxt
  end

  private

    def cleanup_taxts
      self.taxt = Taxt::Cleanup[taxt]
    end
end
