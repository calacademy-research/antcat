class Protonym < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  BIOGEOGRAPHIC_REGIONS = %w[
    Nearctic Neotropic Palearctic Afrotropic Malagasy Indomalaya Australasia Oceania Antarctic
  ]
  # TODO: These are currently stored in `taxa.type_taxt`; we want to move them to `protonyms` or a new model,
  # and normalize the values (see `DatabaseScripts::TaxaWithTypeTaxa`).
  COMMON_TYPE_TAXTS = [
    BY_MONOTYPY = ", by monotypy.",
    BY_ORIGINAL_DESIGNATION = ", by original designation.",
    BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF = /^, by subsequent designation of {ref \d+}: \d+.$/
  ]

  belongs_to :authorship, class_name: 'Citation', dependent: :destroy
  belongs_to :name, dependent: :destroy

  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error
  # TODO: See https://github.com/calacademy-research/antcat/issues/702
  has_many :taxa_with_history_items, -> { distinct.joins(:history_items) }, class_name: 'Taxon'

  validates :authorship, presence: true
  validates :name, presence: true
  # TODO: See if wa want to validate this w.r.t. rank of name and fossil status.
  validates :biogeographic_region, inclusion: { in: BIOGEOGRAPHIC_REGIONS, allow_nil: true }

  before_validation :cleanup_taxts

  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :order_by_name, -> { joins(:name).order('names.name') }

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }
  strip_attributes only: [:locality, :biogeographic_region], replace_newlines: true
  strip_attributes only: [:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt]
  trackable parameters: proc { { name: decorate.format_name } }

  def soft_validation_warnings
    @soft_validation_warnings ||= Protonyms::DatabaseScriptSoftValidationWarnings[self]
  end

  private

    def cleanup_taxts
      self.primary_type_information_taxt = Taxt::Cleanup[primary_type_information_taxt]
      self.secondary_type_information_taxt = Taxt::Cleanup[secondary_type_information_taxt]
      self.type_notes_taxt = Taxt::Cleanup[type_notes_taxt]
    end
end
