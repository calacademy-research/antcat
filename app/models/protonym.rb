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

  belongs_to :authorship, class_name: 'Citation', inverse_of: :protonym, dependent: :destroy
  belongs_to :name, dependent: :destroy
  belongs_to :type_name, optional: true, dependent: :destroy

  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error
  # TODO: See https://github.com/calacademy-research/antcat/issues/702
  has_many :taxa_with_history_items, -> { distinct.joins(:history_items) }, class_name: 'Taxon'
  has_many :history_items, through: :taxa, class_name: 'TaxonHistoryItem'

  # TODO: See if wa want to validate this w.r.t. rank of name.
  validates :biogeographic_region, inclusion: { in: BIOGEOGRAPHIC_REGIONS, allow_nil: true }
  validates :biogeographic_region, absence: { message: "cannot be set for fossil protonyms" }, if: -> { fossil? }

  before_validation :cleanup_taxts

  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :order_by_name, -> { joins(:name).order('names.name') }

  has_paper_trail
  strip_attributes only: [:locality, :biogeographic_region, :forms, :notes_taxt], replace_newlines: true
  strip_attributes only: [:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt]
  trackable parameters: proc { { name: decorate.name_with_fossil } }

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
    string << "(#{forms}) " if forms
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
      self.notes_taxt = Taxt::Cleanup[notes_taxt]
    end
end
