# All `Name` subclasses are for taxa and protonyms; `AuthorName`s are used for references.

class Name < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  NON_ITALIC_NAME_TYPES = %w[FamilyName FamilyOrSubfamilyName SubfamilyName TribeName SubtribeName]
  ITALIC_NAME_TYPES = %w[GenusName SubgenusName SpeciesName SubspeciesName InfrasubspeciesName]
  NAME_TYPES = NON_ITALIC_NAME_TYPES + ITALIC_NAME_TYPES

  # Parentheses are for subgenera, periods for infrasubspecific names (old-style protonyms).
  VALID_CHARACTERS_REGEX = /\A[-a-zA-Z. \(\)]+\z/
  # Two or more words:
  #   `SubgenusName`
  #   `SpeciesName`
  #   `SubspeciesName`
  SINGLE_WORD_NAMES = [
    'FamilyName',
    'FamilyOrSubfamilyName', # TODO: Split into `FamilyName` and `SubfamilyName` and remove.
    'SubfamilyName',
    'TribeName',
    'SubtribeName',
    'GenusName'
  ]
  BROKEN_ISH_NAME_TYPES = ['FamilyOrSubfamilyName'] # TODO

  has_many :protonyms, dependent: :restrict_with_error
  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error

  validates :name, :epithet, presence: true
  validates :name, :epithet,
    format: { with: VALID_CHARACTERS_REGEX, message: "can only contain Latin letters, periods, dashes and parentheses" }
  validate :ensure_no_spaces_in_single_word_names
  validate :ensure_starts_with_upper_case_letter

  after_save :set_taxon_caches
  # NOTE: Technically we don't need to do this, since it *should* not be different, but let's make sure.
  before_validation :set_epithet

  scope :single_word_names, -> { where(type: SINGLE_WORD_NAMES) }
  scope :no_single_word_names, -> { where.not(type: SINGLE_WORD_NAMES) }

  has_paper_trail
  strip_attributes replace_newlines: true
  trackable parameters: proc { { name_html: name_html } }

  # NOTE: This may make code harder to debug, but we don't want to have to manually specify epithets,
  # or have them diverge. Consider this to be a factory or persistence-related callback.
  def name= value
    self[:name] = value.squish if value
    set_epithet
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  def italics?
    self.class.name.in?(ITALIC_NAME_TYPES)
  end

  def name_html
    italicize_if_needed name
  end

  def name_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def owner
    taxa.first || protonyms.first
  end

  def single_word_name?
    type.in? SINGLE_WORD_NAMES
  end

  private

    def italicize_if_needed string
      return string unless italics?
      Italicize[string]
    end

    def dagger_html
      italicize_if_needed '&dagger;'.html_safe
    end

    def set_epithet
      return unless name
      self.epithet = if is_a?(SubgenusName)
                       name_parts.last.tr('()', '')
                     else
                       name_parts.last
                     end
    end

    def ensure_no_spaces_in_single_word_names
      return unless single_word_name?
      return unless name.include?(" ")

      errors.add :name, "of type #{type} may not contain spaces"
      throw :abort
    end

    def ensure_starts_with_upper_case_letter
      return if name.blank?
      return if name[0] == name[0].upcase

      errors.add :name, "must start with a capital letter"
    end

    def name_parts
      name.split
    end

    def set_taxon_caches
      taxa.reload.each do |taxon|
        taxon.name_cache = name
        taxon.name_html_cache = name_html
        taxon.save(validate: false)
      end
    end
end
