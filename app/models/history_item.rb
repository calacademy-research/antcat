# frozen_string_literal: true

class HistoryItem < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  self.inheritance_column = :_type_column_disabled

  alias_attribute :current_taxon_owner, :terminal_taxon

  belongs_to :protonym

  has_one :terminal_taxon, through: :protonym
  has_many :terminal_taxa, through: :protonym

  validates :taxt, presence: true
  validates :rank, inclusion: { in: Rank::AntCatSpecific::TYPE_SPECIFIC_HISTORY_ITEM_TYPES, allow_nil: true }

  before_validation :cleanup_and_convert_taxts

  scope :persisted, -> { where.not(id: nil) }
  scope :unranked_and_for_rank, ->(type) { where(rank: [nil, type]) }
  scope :except_taxts, -> { all } # NOTE: Preparing for hybrid history items. [grep:hybrid].

  acts_as_list scope: :protonym
  has_paper_trail
  strip_attributes only: [:taxt, :rank], replace_newlines: true
  trackable parameters: proc { { protonym_id: protonym_id } }

  def standard_format?
    Taxt::StandardHistoryItemFormats.standard?(taxt)
  end

  def to_taxt
    taxt
  end

  def ids_from_tax_or_taxac_tags
    Taxt.extract_ids_from_tax_or_taxac_tags taxt
  end

  private

    def cleanup_and_convert_taxts
      cleanup_and_convert_taxt_columns :taxt
    end
end
