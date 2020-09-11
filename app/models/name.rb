# frozen_string_literal: true

# All `Name` subclasses are for taxa and protonyms; `AuthorName`s are used for references.

class Name < ApplicationRecord
  include Trackable

  # TODO: Rename to `CONNECTING_TERMS` (and Ctrl+F /rank.abbreviation/i).
  # See https://antcat.org/wiki_pages/12
  RANK_ABBREVIATIONS = [
    'ab.',       # abberratio.
    'f.',        # forma, form.
    'f.interm.', # forma?
    'form.',     # forma.
    'm.',
    'morph.',    # morpha.
    'n.',        # natio.
    'nat.',      # natio.
    'r.',
    'ssp.',      # subspecies.
    'st.',
    'subp.',     # subspecies.
    'subsp.',    # subspecies.
    'v.',        # varietas, variety.
    'var.'       # varietas, variety.
  ]

  # Parentheses are for subgenera, periods for infrasubspecific names (old-style protonyms).
  VALID_CHARACTERS_REGEX = /\A[-a-zA-Z. ()]+\z/
  SINGLE_WORD_NAMES = %w[FamilyName SubfamilyName TribeName SubtribeName GenusName]
  FAMILY_AND_GENUS_GROUP_NAMES = %w[FamilyName SubfamilyName TribeName SubtribeName GenusName SubgenusName]
  SPECIES_GROUP_NAMES = %w[SpeciesName SubspeciesName InfrasubspeciesName]

  has_many :protonyms, dependent: :restrict_with_error
  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error

  validates :name, presence: true
  validates :name,
    format: { with: VALID_CHARACTERS_REGEX, message: "can only contain Latin letters, periods, dashes and parentheses" },
    unless: -> { name.blank? }
  validate :validate_number_of_name_parts, :ensure_starts_with_upper_case_letter

  # NOTE: Technically we don't need to do this, since it *should* not be different, but let's make sure.
  before_validation :set_epithet, :set_cleaned_name
  after_save :set_taxon_name_cache

  scope :single_word_names, -> { where(type: SINGLE_WORD_NAMES) }
  scope :no_single_word_names, -> { where.not(type: SINGLE_WORD_NAMES) }

  has_paper_trail
  strip_attributes only: [:name, :epithet, :gender], replace_newlines: true
  trackable parameters: proc { { name_html: name_html } }

  # NOTE: This may make code harder to debug, but we don't want to have to manually specify epithets,
  # or have them diverge. Consider this to be a factory or persistence-related callback.
  def name= value
    self[:name] = value.squish if value
    set_epithet
  end

  def taxon_type
    @_taxon_type ||= self.class.name.delete_suffix('Name')
  end

  def name_html
    italicize_if_needed name
  end

  def epithet_html
    italicize_if_needed epithet
  end

  def name_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def italic?
    Rank.italic?(taxon_type)
  end

  def owner
    taxa.first || protonyms.first
  end

  private

    def italicize_if_needed string
      return string unless italic?
      Italicize[string]
    end

    def dagger_html
      italicize_if_needed '†'
    end

    def set_epithet
      return unless name
      self.epithet = if is_a?(SubgenusName)
                       name_parts.last.tr('()', '')
                     else
                       name_parts.last
                     end
    end

    def validate_number_of_name_parts
      return if name.blank?

      expected = Rank.number_of_name_parts(taxon_type)
      return if cleaned_name_parts.size == expected

      errors.add :name, "of type #{type} must contains #{expected} word parts (excluding subgenus part and rank abbreviations)"
    end

    def ensure_starts_with_upper_case_letter
      return if name.blank?
      return if name[0] == name[0].upcase

      errors.add :name, "must start with a capital letter"
    end

    def name_parts
      name.split
    end

    def cleaned_name_parts
      cleaned_name.split
    end

    def set_cleaned_name
      self.cleaned_name = Names::CleanName[name]
    end

    def set_taxon_name_cache
      taxa.reload.each do |taxon|
        taxon.name_cache = name
        taxon.save(validate: false)
      end
    end
end
