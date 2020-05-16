# frozen_string_literal: true

# TODO: Add rank to make validations easier.

class Protonym < ApplicationRecord
  include Trackable

  BIOGEOGRAPHIC_REGIONS = [
    NEARCTIC_REGION = 'Nearctic',
    NEOTROPIC_REGION = 'Neotropic',
    'Palearctic',
    'Afrotropic',
    'Malagasy',
    'Indomalaya',
    'Australasia',
    'Oceania',
    'Antarctic'
  ]

  # TODO: These are currently stored in `taxa.type_taxt`; we want to move them to `protonyms` or a new model,
  # and normalize the values (see `DatabaseScripts::MoveTypeTaxonToProtonymByScript`).
  COMMON_TYPE_TAXTS = [
    BY_MONOTYPY = ", by monotypy.",
    BY_ORIGINAL_DESIGNATION = ", by original designation.",
    BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF = /^, by subsequent designation of {ref \d+}: \d+.$/
  ]

  belongs_to :authorship, class_name: 'Citation', inverse_of: :protonym, dependent: :destroy
  belongs_to :name, dependent: :destroy

  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error
  # TODO: See https://github.com/calacademy-research/antcat/issues/702
  has_many :taxa_with_history_items, -> { distinct.joins(:history_items) }, class_name: 'Taxon'
  has_many :history_items, through: :taxa, class_name: 'TaxonHistoryItem'

  # TODO: See if wa want to validate this w.r.t. rank of name and fossil status.
  validates :biogeographic_region, inclusion: { in: BIOGEOGRAPHIC_REGIONS, allow_nil: true }

  before_validation :cleanup_taxts

  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :order_by_name, -> { joins(:name).order('names.name') }

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail
  strip_attributes only: [:locality, :biogeographic_region], replace_newlines: true
  strip_attributes only: [:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt]
  trackable parameters: proc { { name: decorate.name_with_fossil } }

  # TODO: This is "hmm", but I don't want to add it to `Taxon`, so it will live here for now.
  # Migrating all type data will take some time (a lot).
  # :nocov:
  def self.common_type_taxt? type_taxt
    return true unless type_taxt
    return true if type_taxt.in?([BY_MONOTYPY, BY_ORIGINAL_DESIGNATION])
    return true if BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF.match?(type_taxt)
    false
  end
  # :nocov:

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  # :nocov:
  def self.all_taxa_above_genus_and_of_unique_different_ranks? taxa
    ranks = taxa.pluck(:type)
    (ranks - Rank::TYPES_ABOVE_GENUS).empty? && ranks.uniq.size == ranks.size
  end
  # :nocov:

  # :nocov:
  def self.all_statuses_same? taxa
    taxa.pluck(:status).uniq.size == 1
  end
  # :nocov:

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  # :nocov:
  def self.taxa_genus_and_subgenus_pair? taxa
    taxa.pluck(:type).sort == %w[Genus Subgenus]
  end
  # :nocov:

  # TODO: This was added for a db script. Remove once cleared (or make use of it elsewhere).
  # :nocov:
  def synopsis
    formated_locality = decorate.format_locality

    string = +''
    string << "#{authorship.reference.keey}, #{authorship.pages} "
    string << "(#{authorship.forms}) " if authorship.forms
    string << formated_locality + ' ' if formated_locality
    string << biogeographic_region if biogeographic_region
    string
  end
  # :nocov:

  def soft_validations
    @_soft_validations ||= SoftValidations.new(self, SoftValidations::PROTONYM_DATABASE_SCRIPTS_TO_CHECK)
  end

  private

    def cleanup_taxts
      self.primary_type_information_taxt = Taxt::Cleanup[primary_type_information_taxt]
      self.secondary_type_information_taxt = Taxt::Cleanup[secondary_type_information_taxt]
      self.type_notes_taxt = Taxt::Cleanup[type_notes_taxt]
    end
end
