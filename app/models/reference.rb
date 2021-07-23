# frozen_string_literal: true

class Reference < ApplicationRecord
  include Trackable

  CONCRETE_SUBCLASS_NAMES = %w[ArticleReference BookReference NestedReference]
  REVIEW_STATES = [
    REVIEW_STATE_NONE = "none",
    REVIEW_STATE_REVIEWED = "reviewed",
    REVIEW_STATE_REVIEWING = "reviewing"
  ]
  CACHE_COLUMNS = %i[
    plain_text_cache
    expanded_reference_cache
    key_with_suffixed_year_cache
  ]
  IGNORE_PAPER_TRAIL_COLUMNS = CACHE_COLUMNS
  SOLR_IGNORE_ATTRIBUTE_CHANGES_OF = CACHE_COLUMNS

  delegate :routed_url, to: :document
  delegate :key_with_suffixed_year, :key_with_year, to: :key

  has_many :reference_author_names, -> { order(:position) }, inverse_of: :reference, dependent: :destroy
  has_many :author_names, -> { order('reference_author_names.position') }, through: :reference_author_names
  has_many :authors, through: :author_names
  has_many :nestees, class_name: "Reference", foreign_key: :nesting_reference_id, dependent: :restrict_with_error
  has_many :citations, dependent: :restrict_with_error
  has_many :citations_from_type_names, class_name: 'TypeName', dependent: :restrict_with_error # [grep:unify_citations].
  has_many :history_items, class_name: 'HistoryItem', dependent: :restrict_with_error # [grep:unify_citations].
  has_one :document, class_name: 'ReferenceDocument', dependent: :destroy

  validates :year, :pagination, :title, :author_names, presence: true
  validates :year_suffix, format: { with: /\A[a-z]\z/, message: "must be blank or a single lowercase letter", allow_nil: true }
  validates :nesting_reference_id, absence: true, unless: -> { is_a?(NestedReference) }
  validates :doi, format: { with: /\A[^<>]*\z/ }
  validate :ensure_bolton_key_unique

  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :year, :year_suffix) }
  scope :order_by_suffixed_year, -> { order(:year, :year_suffix) }
  scope :unreviewed, -> { where.not(review_state: REVIEW_STATE_REVIEWED) }

  accepts_nested_attributes_for :document, reject_if: proc { |attrs| attrs['file'].blank? && attrs['url'].blank? }
  has_paper_trail ignore: IGNORE_PAPER_TRAIL_COLUMNS
  strip_attributes only: [
    :public_notes, :editor_notes, :taxonomic_notes, :title, :date, :stated_year, :year_suffix,
    :series_volume_issue, :doi, :bolton_key, :author_names_suffix, :normalized_bolton_key
  ], replace_newlines: true
  trackable parameters: proc { { name: key_with_suffixed_year } }

  searchable(ignore_attribute_changes_of: SOLR_IGNORE_ATTRIBUTE_CHANGES_OF) do
    string(:type)
    integer(:year)
    text(:author_names_string)
    text(:author_names_string, as: :author_names_string_antcat_text)
    text(:suffixed_year)
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
    text(:authors_for_key) { key.authors_for_key } # To find "et al".
    string(:suffixed_year)
    string(:stated_year)
    string(:doi)
    string(:author_names_string)
  end

  def downloadable?
    !!document
  end

  # TODO: Something regarding "_cache" vs. "string" vs. not.
  # Looks like: "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.".
  def author_names_string
    author_names_string_cache
  end

  def author_names_string_with_suffix
    string = author_names_string.dup
    string << " #{author_names_suffix}" if author_names_suffix
    string
  end

  # TODO: Probably get rid of this and `#refresh_author_names_cache!`.
  def refresh_author_names_cache
    self.author_names_string_cache = author_names.map(&:name).join('; ').strip
  end

  def refresh_author_names_cache!
    refresh_author_names_cache
    save!(validate: false)
  end

  def refresh_key_with_suffixed_year_cache
    self.key_with_suffixed_year_cache = key_with_suffixed_year
  end

  def refresh_key_with_suffixed_year_cache!
    refresh_key_with_suffixed_year_cache
    save!(validate: false)
  end

  # Looks like: '2000a ("2001")' (and simply just the year if `suffixed_year` and `stated_year` are blank).
  def suffixed_year_with_stated_year
    return suffixed_year unless stated_year
    %(#{suffixed_year} ("#{stated_year}"))
  end

  def suffixed_year
    "#{year}#{year_suffix}"
  end

  def full_pagination
    pagination
  end

  def key
    @_key ||= References::Key.new(self)
  end

  private

    def ensure_bolton_key_unique
      return unless bolton_key
      return unless (conflict = self.class.where(bolton_key: bolton_key).where.not(id: id).first)
      errors.add :bolton_key, "Bolton key has already been taken by #{conflict.decorate.link_to_reference}."
    end
end
