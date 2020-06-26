# frozen_string_literal: true

class Reference < ApplicationRecord
  include WorkflowActiverecord
  include Trackable
  include References::Concerns::Searchable

  CONCRETE_SUBCLASS_NAMES = %w[ArticleReference BookReference NestedReference]
  REVIEW_STATES = [
    REVIEW_STATE_NONE = "none",
    REVIEW_STATE_REVIEWED = "reviewed",
    REVIEW_STATE_REVIEWING = "reviewing"
  ]

  delegate :routed_url, :downloadable?, to: :document, allow_nil: true
  delegate :keey, :key_with_year, to: :key

  has_many :reference_author_names, -> { order(:position) }, dependent: :destroy
  has_many :author_names, -> { order('reference_author_names.position') }, through: :reference_author_names,
    after_add: :refresh_author_names_cache, after_remove: :refresh_author_names_cache
  has_many :authors, through: :author_names
  has_many :nestees, class_name: "Reference", foreign_key: :nesting_reference_id, dependent: :restrict_with_error
  has_many :citations, dependent: :restrict_with_error
  has_one :document, class_name: 'ReferenceDocument', dependent: false # TODO: See if we want to destroy it.

  validates :year, :pagination, :title, :author_names, presence: true
  validates :nesting_reference_id, absence: true, unless: -> { is_a?(NestedReference) }
  validates :citation_year, format: { with: /\A\d{4,}[a-z]?\z/, message: "must be a year, followed by an optional lowercase letter" }
  validates :doi, format: { with: /\A[^<>]*\z/ }
  validate :ensure_bolton_key_unique

  before_validation :set_year_from_citation_year
  before_save :assign_author_names_cache

  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :citation_year) }
  scope :unreviewed, -> { where.not(review_state: REVIEW_STATE_REVIEWED) }

  accepts_nested_attributes_for :document, reject_if: proc { |attrs| attrs['file'].blank? && attrs['url'].blank? }
  has_paper_trail
  strip_attributes only: [
    :public_notes, :editor_notes, :taxonomic_notes, :title, :date, :stated_year,
    :series_volume_issue, :doi, :bolton_key, :author_names_suffix
  ], replace_newlines: true
  trackable parameters: proc { { name: keey } }

  workflow_column :review_state
  workflow do
    state(:none)      { event :start_reviewing,   transitions_to: :reviewing }
    state(:reviewing) { event :finish_reviewing,  transitions_to: :reviewed }
    state(:reviewed)  { event :restart_reviewing, transitions_to: :reviewing }
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
  def refresh_author_names_cache *_args
    assign_author_names_cache
    save(validate: false)
  end

  def citation_year_with_stated_year
    return citation_year unless stated_year
    %(#{citation_year} ("#{stated_year}"))
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

    def set_year_from_citation_year
      self.year = if citation_year.present?
                    citation_year.to_i
                  end
    end

    def assign_author_names_cache
      self.author_names_string_cache = author_names.map(&:name).join('; ').strip
    end
end
