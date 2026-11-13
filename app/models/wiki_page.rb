# frozen_string_literal: true

class WikiPage < ApplicationRecord
  include Trackable

  TITLE_MAX_LENGTH = 70

  PERMANENT_IDENTIFIERS = [
    SPECIES_GROUP_NAMES_CONNECTING_TERMS = 'species_group_names_connecting_terms',
    FORMS = 'forms',
    NEW_CONTRIBUTORS_HELP_PAGE = 'new_contributors_help_page',
    TYPE_INFORMATION = 'type_information',
    GRAMMAR_AND_SPELLING_POLICY = 'grammar_and_spelling_policy'
  ]

  MissingWikiPage = Struct.new(:permanent_identifier) do
    def title
      "Error: Could not find wiki page '#{permanent_identifier}'"
    end

    def to_model
      WikiPage.new
    end
  end

  # Protonyms whose grammar and spelling this page documents ("Grammar and spelling: <name>").
  has_many :grammar_and_spelling_protonyms, class_name: 'Protonym', foreign_key: :grammar_and_spelling_wiki_page_id,
    dependent: :restrict_with_error, inverse_of: :grammar_and_spelling_wiki_page

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }, uniqueness: { case_sensitive: true }
  validates :content, presence: true
  validates :permanent_identifier, uniqueness: { case_sensitive: true, allow_nil: true }

  has_paper_trail
  trackable parameters: proc { { title: title } }

  scope :featured, -> { where(featured: true) }

  def self.from_permanent_identifier_or_missing permanent_identifier
    find_by(permanent_identifier: permanent_identifier) || MissingWikiPage.new(permanent_identifier)
  end
end
