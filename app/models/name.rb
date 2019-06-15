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
  BROKEN_ISH_NAME_TYPES = ['FamilyOrSubfamilyName', 'SubtribeName'] # TODO

  has_many :protonyms, dependent: :restrict_with_error
  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error

  validates :name, :epithet, presence: true
  validates :name, :epithet,
    format: { with: VALID_CHARACTERS_REGEX, message: "can only contain Latin letters, periods, dashes and parentheses" }
  validate :ensure_no_spaces_in_single_word_names
  validate :ensure_epithet_in_name

  after_save :set_taxon_caches

  scope :single_word_names, -> { where(type: SINGLE_WORD_NAMES) }
  scope :no_single_word_names, -> { where.not(type: SINGLE_WORD_NAMES) }

  # TODO: Remove once we can fully prevent new cases (including name conflicts from undoing changes).
  scope :orphaned, -> { Name.left_outer_joins(:taxa, :protonyms).where("protonyms.id IS NULL AND taxa.id IS NULL") }
  scope :not_orphaned, -> { Name.where.not(id: orphaned.select(:id)) } # `Taxon.count + Protonym.count`

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes replace_newlines: true
  trackable parameters: proc { { name_html: name_html } }

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

    def ensure_epithet_in_name
      return if name.blank? || epithet.blank?
      return if name.include?(epithet)

      errors.add :epithet, "must occur in the full name"
      throw :abort
    end

    def ensure_no_spaces_in_single_word_names
      return unless single_word_name?

      if name.include?(" ")
        errors.add :name, "of type #{type} may not contain spaces"
        throw :abort
      end
    end

    def words
      @words ||= name.split
    end

    def set_taxon_caches
      Taxon.where(name: self).update_all(name_cache: name, name_html_cache: name_html)
    end
end
