# All `Name` subclasses are for taxa and protonyms; `AuthorName`s are used for references.

class Name < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

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
  validate :ensure_epithet_in_name
  validate :ensure_starts_with_upper_case_letter

  after_save :set_taxon_caches
  # NOTE: Technically we don't need to do this, since they *should* not be different, but let's make sure.
  before_validation :set_epithet, :set_epithets

  scope :single_word_names, -> { where(type: SINGLE_WORD_NAMES) }
  scope :no_single_word_names, -> { where.not(type: SINGLE_WORD_NAMES) }

  # TODO: Remove once we can fully prevent new cases (including name conflicts from undoing changes).
  scope :orphaned, -> { Name.left_outer_joins(:taxa, :protonyms).where("protonyms.id IS NULL AND taxa.id IS NULL") }
  scope :not_orphaned, -> { Name.where.not(id: orphaned.select(:id)) } # `Taxon.count + Protonym.count`

  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }
  strip_attributes replace_newlines: true
  trackable parameters: proc { { name_html: name_html } }

  # NOTE: This may make code harder to debug, but we don't want to have to manually specify epithets,
  # or have them diverge. Consider this to be a factory or persistence-related callback.
  def name=(value)
    self[:name] = value.squish if value
    set_epithet
    set_epithets
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  def name_html
    name
  end

  def epithet_html
    epithet
  end

  def name_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def epithet_with_fossil_html fossil
    "#{dagger_html if fossil}#{epithet_html}".html_safe
  end

  def dagger_html
    '&dagger;'.html_safe
  end

  def what_links_here
    Names::WhatLinksHere[self]
  end

  def orphaned?
    !(taxa.exists? || protonyms.exists?)
  end

  def single_word_name?
    type.in? SINGLE_WORD_NAMES
  end

  private

    def set_epithet
      return unless name
      self.epithet = if is_a?(SubgenusName)
                       name_parts.last.tr('()', '')
                     else
                       name_parts.last
                     end
    end

    def set_epithets
      return unless name
      return unless is_a?(SpeciesGroupName)

      self.epithets = if name_parts.size > 2
                        name_parts[1..-1].join(' ')
                      end
    end

    def ensure_epithet_in_name
      return if name.blank? || epithet.blank?
      return if name.include?(epithet)

      errors.add :epithet, "must occur in the full name"
      throw :abort
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
