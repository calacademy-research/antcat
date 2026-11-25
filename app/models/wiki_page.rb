# frozen_string_literal: true

# A help page of the site; some have a permanent identifier the code links to (table `wiki_pages`).
class WikiPage < ApplicationRecord
  include Trackable

  TITLE_MAX_LENGTH = 70

  PERMANENT_IDENTIFIERS = [
    SPECIES_GROUP_NAMES_CONNECTING_TERMS = 'species_group_names_connecting_terms',
    FORMS = 'forms',
    NEW_CONTRIBUTORS_HELP_PAGE = 'new_contributors_help_page',
    TYPE_INFORMATION = 'type_information',
    GRAMMAR_AND_SPELLING_POLICY = 'grammar_and_spelling_policy',
    DERIVED_ETYMOLOGIES_POLICY = 'derived_etymologies_policy',
    OPEN_GRAMMAR_AND_SPELLING_QUESTIONS = 'open_grammar_and_spelling_questions'
  ]
  # AntCat's public policies, in the order they are listed (wiki index, linked from the footer): pages for readers
  # of the catalog, not how-tos for editors. The footer's "Policies" shows these alone.
  POLICY_IDENTIFIERS = [GRAMMAR_AND_SPELLING_POLICY, DERIVED_ETYMOLOGIES_POLICY, OPEN_GRAMMAR_AND_SPELLING_QUESTIONS]

  MissingWikiPage = Struct.new(:permanent_identifier) do
    def title
      "Error: Could not find wiki page '#{permanent_identifier}'"
    end

    def to_model
      WikiPage.new
    end
  end

  # The wiki link of 13 Nov 2026 (`protonyms.grammar_and_spelling_wiki_page_id`), no longer used; notes on a name
  # are a `NotesPage` now. Kept, with the column and its foreign key, so that a page some protonym still points
  # to is refused with a message, not a database error. Goes with the migration that removes the column.
  has_many :grammar_and_spelling_protonyms, class_name: 'Protonym', foreign_key: :grammar_and_spelling_wiki_page_id,
    dependent: :restrict_with_error, inverse_of: false

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }, uniqueness: { case_sensitive: true }
  validates :content, presence: true
  validates :permanent_identifier, uniqueness: { case_sensitive: true, allow_nil: true }

  has_paper_trail
  trackable parameters: proc { { title: title } }

  scope :featured, -> { where(featured: true) }

  # The policy pages that exist, in the order of `POLICY_IDENTIFIERS`.
  def self.policies
    where(permanent_identifier: POLICY_IDENTIFIERS).
      sort_by { |wiki_page| POLICY_IDENTIFIERS.index(wiki_page.permanent_identifier) }
  end

  before_validation { self.permanent_identifier = permanent_identifier.presence }

  def self.from_permanent_identifier_or_missing permanent_identifier
    find_by(permanent_identifier: permanent_identifier) || MissingWikiPage.new(permanent_identifier)
  end

  def policy?
    POLICY_IDENTIFIERS.include?(permanent_identifier)
  end
end
