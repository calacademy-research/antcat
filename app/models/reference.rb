# frozen_string_literal: true

class Reference < ApplicationRecord
  include WorkflowActiverecord
  include Trackable

  CONCRETE_SUBCLASS_NAMES = %w[ArticleReference BookReference NestedReference]
  REVIEW_STATES = [
    REVIEW_STATE_NONE = "none",
    REVIEW_STATE_REVIEWED = "reviewed",
    REVIEW_STATE_REVIEWING = "reviewing"
  ]
  SOLR_IGNORE_ATTRIBUTE_CHANGES_OF = %i[plain_text_cache expandable_reference_cache expanded_reference_cache]

  has_many :reference_author_names, -> { order(:position) }, dependent: :destroy
  has_many :author_names, -> { order('reference_author_names.position') },
    through: :reference_author_names,
    after_add: :refresh_author_names_cache,
    after_remove: :refresh_author_names_cache
  has_many :authors, through: :author_names
  has_many :nestees, class_name: "Reference", foreign_key: :nesting_reference_id, dependent: :restrict_with_error
  has_many :citations, dependent: :restrict_with_error
  has_many :protonyms, through: :citations
  has_many :described_taxa, through: :protonyms, source: :taxa
  has_one :document, class_name: 'ReferenceDocument', dependent: false # TODO: See if we want to destroy it.

  validates :type, inclusion: { in: CONCRETE_SUBCLASS_NAMES }
  validates :year, :pagination, :title, :author_names, presence: true
  validates :nesting_reference_id, absence: true, unless: -> { is_a?(NestedReference) }
  validates :doi, format: { with: /\A[^<>]*\z/ }
  validate :ensure_bolton_key_unique

  before_validation :set_year_from_citation_year
  before_save :assign_author_names_cache
  before_destroy :check_not_referenced

  scope :latest_additions, -> { order(created_at: :desc) }
  scope :latest_changes, -> { order(updated_at: :desc) }
  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :citation_year) }
  scope :unreviewed, -> { where.not(review_state: "reviewed") }

  accepts_nested_attributes_for :document, reject_if: proc { |attrs| attrs['file'].blank? && attrs['url'].blank? }
  delegate :routed_url, :downloadable?, to: :document, allow_nil: true
  has_paper_trail
  strip_attributes only: [
    :public_notes, :editor_notes, :taxonomic_notes, :title, :date, :citation_year, :stated_year,
    :series_volume_issue, :pagination, :doi, :review_state, :bolton_key, :author_names_suffix
  ], replace_newlines: true
  trackable parameters: proc { { name: keey } }

  searchable(ignore_attribute_changes_of: SOLR_IGNORE_ATTRIBUTE_CHANGES_OF) do
    string(:type)
    integer(:year)
    text(:author_names_string)
    text(:citation_year)
    text(:stated_year)
    text(:title)
    # NOTE: Safe navigation for `.name` is for journals/publishers created at the same time as the reference.
    text(:journal_name) { journal&.name if respond_to?(:journal) }
    text(:publisher_name) { publisher&.name if respond_to?(:publisher) }
    text(:year_as_string) { year.to_s }
    text(:public_notes)
    text(:editor_notes)
    text(:taxonomic_notes)
    text(:bolton_key)
    text(:authors_for_keey) { authors_for_keey } # To find "et al".
    string(:citation_year)
    string(:stated_year)
    string(:doi)
    string(:author_names_string)
  end

  workflow_column :review_state
  workflow do
    state :none do
      event :start_reviewing, transitions_to: :reviewing
    end
    state :reviewing do
      event :finish_reviewing, transitions_to: :reviewed
    end
    state :reviewed do
      event :restart_reviewing, transitions_to: :reviewing
    end
  end

  # TODO: Something. "_cache" vs not.
  # Looks like: "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.".
  def author_names_string
    author_names_string_cache
  end

  def author_names_string_with_suffix
    string = author_names_string
    string << " #{author_names_suffix}" if author_names_suffix
    string
  end

  # TODO: See if we can avoid this.
  def refresh_author_names_cache *args
    assign_author_names_cache args
    save(validate: false)
  end

  # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978".
  def keey
    authors_for_keey << ', ' << citation_year_without_extras
  end

  # Normal keey: "Bolton, 1885g".
  # This:        "Bolton, 1885".
  def keey_without_letters_in_year
    authors_for_keey << ', ' << year.to_s
  end

  # TODO: Replace `citation_year_without_extras` with `citation_year` once "extras" has been moved to `stated_year`.
  # See https://github.com/calacademy-research/antcat/issues/977
  def citation_year_and_stated_year
    return citation_year_without_extras unless stated_year
    %(#{citation_year_without_extras} ("#{stated_year}"))
  end

  def authors_for_keey
    names = author_names.map(&:last_name)
    case names.size
    when 0 then '[no authors]' # TODO: This can still happen in the reference form.
    when 1 then names.first.to_s
    when 2 then "#{names.first} & #{names.second}"
    else        "#{names.first} <i>et al.</i>"
    end.html_safe
  end

  def what_links_here predicate: false
    References::WhatLinksHere[self, predicate: predicate]
  end

  private

    def ensure_bolton_key_unique
      return unless bolton_key
      return unless (conflict = self.class.where(bolton_key: bolton_key).where.not(id: id).first)

      errors.add :bolton_key, "Bolton key has already been taken by #{conflict.decorate.link_to_reference}."
    end

    # TODO: Replace with `citation_year` once "extras" has been moved to `stated_year`.
    def citation_year_without_extras
      return if citation_year.blank?
      citation_year.gsub(/ .*$/, '')
    end

    def check_not_referenced
      return if what_links_here.empty?

      errors.add :base, "This reference can't be deleted, as there are other references to it."
      throw :abort
    end

    def set_year_from_citation_year
      self.year = if citation_year.present?
                    citation_year.to_i
                  end
    end

    def assign_author_names_cache *_args
      self.author_names_string_cache = author_names.map(&:name).join('; ').strip
    end
end
