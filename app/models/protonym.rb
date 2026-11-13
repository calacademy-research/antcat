# frozen_string_literal: true

# TODO: Add rank to make validations easier.

class Protonym < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  BIOREGIONS = [
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

  CHANGEABLE_GENDER_AGREEMENT_TYPES = [
    ADJECTIVE = 'adjective',
    PARTICIPLE = 'participle'
  ]
  UNCHANGEABLE_GENDER_AGREEMENT_TYPES = [
    NOUN_IN_APPOSITION = 'noun_in_apposition',
    NOUN_IN_GENITIVE_CASE = 'noun_in_genitive_case'
  ]
  GENDER_AGREEMENT_TYPES = CHANGEABLE_GENDER_AGREEMENT_TYPES + UNCHANGEABLE_GENDER_AGREEMENT_TYPES
  # The spelling of an adjectival or participial name in each genus gender (TaxonWorks stores the same three).
  GENDER_EPITHET_COLUMNS = {
    'masculine' => :masculine_epithet,
    'feminine' => :feminine_epithet,
    'neuter' => :neuter_epithet
  }.freeze
  # Why AntCat reads the name as this part of speech (the grammatical basis).
  PART_OF_SPEECH_BASES = {
    'author_stated' => 'stated by the original author',
    'grammatical_form' => 'the grammatical form of the epithet (Art. 31.2)',
    'decisive_usage' => 'decisive subsequent usage (Art. 31.2.2)',
    'noun_by_default' => 'noun in apposition by default, usage not decisive (Art. 31.2.2)',
    'commission_ruling' => 'a ruling of the Commission'
  }.freeze
  # Why AntCat accepts the spelling it uses (the nomenclatural basis). A name can be a noun
  # under Art. 31.2.2 and still keep a later spelling under Art. 33.3.1; the two are recorded apart.
  SPELLING_BASES = {
    'original_spelling' => 'the correct original spelling (Art. 32.2)',
    'gender_agreement' => 'the ending agrees with the gender of the genus (Arts. 31.2, 34.2)',
    'justified_emendation' => 'a justified emendation (Arts. 32.5, 33.2.2)',
    'unjustified_emendation_in_prevailing_usage' => 'an unjustified emendation in prevailing usage (Art. 33.2.3.1)',
    'incorrect_subsequent_spelling_in_prevailing_usage' =>
      'an incorrect subsequent spelling in prevailing usage (Art. 33.3.1)',
    'commission_ruling' => 'a ruling of the Commission'
  }.freeze

  delegate :pages, to: :authorship, prefix: true

  belongs_to :authorship, class_name: 'Citation', inverse_of: :protonym, dependent: :destroy
  belongs_to :name, dependent: :destroy
  belongs_to :type_name, optional: true, dependent: :destroy

  with_options class_name: 'Taxon' do
    has_many :taxa, dependent: :restrict_with_error
    has_one :original_combination, -> { original_combinations }
    has_one :terminal_taxon, -> { where(status: Status::TERMINAL_STATUSES) }
    has_many :terminal_taxa, -> { where(status: Status::TERMINAL_STATUSES) }
    has_many :non_terminal_taxa, -> { where.not(status: Status::TERMINAL_STATUSES) }
  end
  has_many :history_items, -> { order(:position) }, dependent: :restrict_with_error
  has_many :history_items_as_object, class_name: 'HistoryItem', foreign_key: :object_protonym_id, dependent: false
  has_one :authorship_reference, through: :authorship, source: :reference

  validates :bioregion, inclusion: { in: BIOREGIONS, allow_nil: true }
  validates :bioregion, absence: { message: "cannot be set for fossil protonyms" }, if: -> { fossil? }
  validates :bioregion, :forms, :locality, :gender_agreement_type, :part_of_speech_basis, :spelling_basis,
    absence: { message: "can only be set for species-group names" },
    unless: -> { species_group_name? }
  validates :part_of_speech_basis, inclusion: { in: PART_OF_SPEECH_BASES.keys, allow_nil: true }
  validates :part_of_speech_basis, absence: { message: "needs a gender agreement type" },
    unless: -> { gender_agreement_type? }
  validates :spelling_basis, inclusion: { in: SPELLING_BASES.keys, allow_nil: true }
  validate :contested_interpretation_has_public_note
  validates :gender_agreement_type, inclusion: { in: GENDER_AGREEMENT_TYPES, allow_nil: true }
  validates :masculine_epithet, :feminine_epithet, :neuter_epithet,
    absence: { message: "can only be set when the gender agreement type is adjective or participle" },
    unless: -> { changeable_name? }
  validates :masculine_epithet, :feminine_epithet, :neuter_epithet,
    format: { with: /\A[a-z]+\z/, message: "must be a single lowercase epithet", allow_nil: true }
  validates :ichnotaxon, absence: { message: "can only be set for fossil protonyms" }, unless: -> { fossil? }

  before_validation :cleanup_and_convert_taxts

  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :order_by_name, -> { joins(:name).order('names.name') }
  scope :family_group_names, -> { joins(:name).where(names: { type: Name::FAMILY_GROUP_NAMES }) }
  scope :genus_group_names, -> { joins(:name).where(names: { type: Name::GENUS_GROUP_NAMES }) }
  scope :species_group_names, -> { joins(:name).where(names: { type: Name::SPECIES_GROUP_NAMES }) }

  has_paper_trail
  strip_attributes only: [
    :locality, :bioregion, :forms, :gender_agreement_type,
    :masculine_epithet, :feminine_epithet, :neuter_epithet,
    :part_of_speech_basis, :spelling_basis,
    :notes_taxt, :etymology_taxt
  ], replace_newlines: true
  strip_attributes only: [:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt]
  trackable parameters: proc { { name: name_with_fossil } }

  searchable do
    text(:name) { name.name }
    text(:authors) { authorship_reference.key.plain_text_authors_for_key }
    text(:year_as_string) { authorship_reference.year.to_s }
  end

  # TODO: Cheating a little bit to avoid making an additional query when parsing `prott` tags.
  def self.terminal_taxon_from_protonym_id protonym_id
    Taxon.where(status: Status::TERMINAL_STATUSES).find_by(protonym_id: protonym_id)
  end

  def author_citation
    authorship_reference.key_with_year
  end

  # As `author_citation`, without markup (autocomplete JSON shown as text).
  def plain_text_author_citation
    authorship_reference.key.plain_text_key_with_year
  end

  def changeable_name?
    gender_agreement_type.in?(CHANGEABLE_GENDER_AGREEMENT_TYPES)
  end

  def unchangeable_name?
    gender_agreement_type.in?(UNCHANGEABLE_GENDER_AGREEMENT_TYPES)
  end

  # @return [Hash, nil] e.g. { "masculine" => "crassispinus", "feminine" => "crassispina", "neuter" => "crassispinum" }
  def gender_epithets
    return unless changeable_name? && GENDER_EPITHET_COLUMNS.values.any? { |column| self[column].present? }
    GENDER_EPITHET_COLUMNS.transform_values { |column| self[column] }
  end

  # The spelling this name takes in a genus of `gender` ("masculine", "feminine" or "neuter").
  def epithet_for_gender gender
    column = GENDER_EPITHET_COLUMNS[gender]
    self[column] if column && changeable_name?
  end

  # The three spellings TaxonWorks would predict from the original epithet (for adjectives and participles only).
  def predicted_gender_epithets
    return unless species_group_name? && name.epithet.present?
    Protonyms::PredictGenderEpithets[name.epithet]
  end

  def part_of_speech_basis_label
    PART_OF_SPEECH_BASES[part_of_speech_basis]
  end

  def spelling_basis_label
    SPELLING_BASES[spelling_basis]
  end

  def genus_group_name?
    Rank.genus_group_name?(rank_from_name)
  end

  def species_group_name?
    return false unless name
    Rank.species_group_name?(rank_from_name)
  end

  def name_with_fossil
    name.name_with_fossil_html(fossil?)
  end

  def rank_from_name
    name.taxon_type
  end

  def soft_validations
    @_soft_validations ||= DbScriptSoftValidations.new(self, DbScriptSoftValidations::PROTONYM_DATABASE_SCRIPTS_TO_CHECK)
  end

  private

    # A contested reading is only transparent if visitors can read the alternative: the note must
    # have text outside hidden editor notes (`{hiddennote ...}`, which visitors do not see).
    def contested_interpretation_has_public_note
      return unless interpretation_contested?
      return if Taxt.remove_hidden_notes(notes_taxt.to_s).strip.present?

      errors.add :interpretation_contested,
        "needs a public note that gives the alternative interpretation and its evidence"
    end

    def cleanup_and_convert_taxts
      cleanup_and_convert_taxt_columns(
        :etymology_taxt,
        :primary_type_information_taxt,
        :secondary_type_information_taxt,
        :type_notes_taxt,
        :notes_taxt
      )
    end
end
