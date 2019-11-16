class Reference < ApplicationRecord
  include Workflow
  include RevisionsCanBeCompared
  include Trackable

  SOLR_IGNORE_ATTRIBUTE_CHANGES_OF = %i[
    plain_text_cache
    expandable_reference_cache
    expanded_reference_cache
  ]

  attr_accessor :journal_name, :publisher_string

  belongs_to :journal
  belongs_to :publisher

  has_many :reference_author_names, -> { order(:position) }, dependent: :destroy
  has_many :author_names, -> { order('reference_author_names.position') },
    through: :reference_author_names,
    after_add: :refresh_author_names_caches,
    after_remove: :refresh_author_names_caches
  has_many :authors, through: :author_names
  has_many :nestees, class_name: "Reference", foreign_key: "nesting_reference_id", dependent: :restrict_with_error
  has_many :citations, dependent: :restrict_with_error
  has_many :protonyms, through: :citations
  has_many :described_taxa, through: :protonyms, source: :taxa
  has_one :document, class_name: 'ReferenceDocument'

  validates :title, presence: true
  validates :nesting_reference_id, absence: true, unless: -> { is_a?(NestedReference) }
  validates :doi, format: { with: /\A[^<>]*\z/ }
  validate :ensure_bolton_key_unique

  before_validation :set_year_from_citation_year
  before_save :set_author_names_caches
  before_destroy :check_not_referenced

  scope :latest_additions, -> { order(created_at: :desc) }
  scope :latest_changes, -> { order(updated_at: :desc) }
  scope :no_missing, -> { where.not(type: "MissingReference") }
  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :citation_year) }
  scope :unreviewed, -> { where.not(review_state: "reviewed") }

  accepts_nested_attributes_for :document, reject_if: :all_blank
  delegate :url, :downloadable?, to: :document, allow_nil: true
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:editor_notes, :public_notes, :taxonomic_notes, :title,
    :citation, :date, :citation_year, :series_volume_issue, :pagination,
    :pages_in, :doi, :reason_missing, :review_state, :bolton_key, :author_names_suffix], replace_newlines: true
  trackable parameters: proc { { name: keey } }

  searchable(ignore_attribute_changes_of: SOLR_IGNORE_ATTRIBUTE_CHANGES_OF) do
    string  :type
    integer :year
    text    :author_names_string
    text    :citation_year
    text    :title
    text    :journal_name do journal.name if journal end
    text    :publisher_name do publisher.name if publisher end
    text    :year_as_string do year.to_s if year end
    text    :citation
    text    :editor_notes
    text    :public_notes
    text    :taxonomic_notes
    text    :bolton_key
    text    :authors_for_keey do authors_for_keey end # To find "et al".
    string  :citation_year
    string  :doi
    string  :author_names_string
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

  def invalidate_caches
    References::Cache::Invalidate[self]
  end

  def set_cache value, field
    References::Cache::Set[self, value, field]
  end

  # TODO: Something. "_cache" vs not.
  # Looks like: "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.".
  def author_names_string
    author_names_string_cache
  end

  def author_names_string_with_suffix
    string = author_names_string
    string << " #{author_names_suffix}" if author_names_suffix.present?
    string
  end

  def refresh_author_names_caches(*args)
    set_author_names_caches args
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

  def authors_for_keey
    names = author_names.map &:last_name
    case names.size
    when 0 then '[no authors]'
    when 1 then "#{names.first}"
    when 2 then "#{names.first} & #{names.second}"
    else        "#{names.first} <i>et al.</i>"
    end.html_safe
  end

  def principal_author_last_name
    author_names.first&.last_name
  end

  def any_notes?
    [public_notes, editor_notes, taxonomic_notes].reject(&:blank?).any?
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

    def citation_year_without_extras
      citation_year.gsub(%r{ .*$}, '')
    end

    def check_not_referenced
      return unless what_links_here(predicate: true)

      errors.add :base, "This reference can't be deleted, as there are other references to it."
      throw :abort
    end

    # TODO: Revisit once missing references have been cleared.
    # `Reference.where(citation_year: nil).group(:type).count # {"MissingReference"=>88}`
    def set_year_from_citation_year
      self.year = if citation_year.blank?
                    nil
                  elsif (match = citation_year.match(/\["(\d{4})"\]/))
                    match[1]
                  else
                    citation_year.to_i
                  end
    end

    def set_author_names_caches(*)
      self.author_names_string_cache = author_names.map(&:name).join('; ').strip
    end
end
