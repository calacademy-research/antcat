# TODO avoid `require`.
# TODO remove `references.principal_author_last_name_cache`.

require_dependency 'references/reference_has_document'
require_dependency 'references/reference_workflow'

class Reference < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  attr_accessor :journal_name, :publisher_string

  belongs_to :journal
  belongs_to :publisher

  has_many :reference_author_names, -> { order(:position) }
  has_many :author_names, -> { order('reference_author_names.position') },
    through: :reference_author_names,
    after_add: :refresh_author_names_caches,
    after_remove: :refresh_author_names_caches
  has_many :authors, through: :author_names
  has_many :nestees, class_name: "Reference", foreign_key: "nesting_reference_id"
  has_many :citations
  has_many :protonyms, through: :citations
  has_many :described_taxa, through: :protonyms, source: :taxa

  validates :title, presence: true
  validates :doi, format: { with: /\A[^<>]*\z/ }

  before_validation :set_year_from_citation_year
  before_save :set_author_names_caches
  before_destroy :check_not_referenced, :check_not_nested

  scope :includes_document, -> { includes(:document) }
  scope :latest_additions, -> { order(created_at: :desc) }
  scope :latest_changes, -> { order(updated_at: :desc) }
  scope :no_missing, -> { where.not(type: "MissingReference") }
  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :citation_year) }
  scope :unreviewed, -> { where.not(review_state: "reviewed") }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:editor_notes, :public_notes, :taxonomic_notes, :title,
    :citation, :date, :citation_year, :series_volume_issue, :pagination,
    :pages_in, :doi, :reason_missing, :review_state, :bolton_key, :author_names_suffix], replace_newlines: true
  tracked on: :mixin_create_activity_only, parameters: proc { { name: keey } }

  searchable do
    string  :type
    integer :year
    text    :author_names_string
    text    :citation_year
    text    :doi, as: :doi
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
    string  :author_names_string
  end

  def self.approve_all
    count = Reference.unreviewed.count
    Feed.without_tracking { Reference.unreviewed.find_each &:approve }
    Activity.create_without_trackable :approve_all_references, parameters: { count: count }
  end

  def invalidate_caches
    References::Cache::Invalidate[self]
  end

  def set_cache value, field
    References::Cache::Set[self, value, field]
  end

  # TODO something. "_cache" vs not.
  # Looks like: "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.".
  def author_names_string
    author_names_string_cache
  end

  def author_names_string_with_suffix
    string = author_names_string
    string << " #{author_names_suffix}" if author_names_suffix.present?
    string
  end

  # TODO we should probably have `#year` [int] and something
  # like `#non_standard_year` [string] instead of this +
  # `#year` + `#citation_year`.
  # TODO what is this used for?
  def short_citation_year
    return "[no year]" if citation_year.blank?
    citation_year.gsub %r{ .*$}, ''
  end

  def refresh_author_names_caches(*)
    update_attribute :author_names_string_cache, make_author_names_string_cache
  end

  # TODO merge into Workflow. Only used for `.approve_all`,
  # which approves all unreviewed references of any state (which Workflow doesn't allow).
  def approve
    self.review_state = "reviewed"
    save!
    Feed.with_tracking { create_activity :finish_reviewing }
  end

  # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978".
  def keey
    authors_for_keey << ', ' << short_citation_year
  end

  # Normal keey: "Bolton, 1885g".
  # This:        "Bolton, 1885".
  def keey_without_letters_in_year
    authors_for_keey << ', ' << year_or_no_year
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

  def year_or_no_year
    return "[no year]" if year.blank?
    year.to_s
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

    def check_not_referenced
      return unless what_links_here(predicate: true)

      errors.add :base, "This reference can't be deleted, as there are other references to it."
      throw :abort
    end

    def check_not_nested
      return unless nestees.exists?

      errors.add :base, "This reference can't be deleted because it's nested in #{nestees.reload.first.id}"
      throw :abort
    end

    def set_year_from_citation_year
      # rubocop:disable Lint/AssignmentInCondition
      self.year = if citation_year.blank?
                    nil
                  elsif match = citation_year.match(/\["(\d{4})"\]/)
                    match[1]
                  else
                    citation_year.to_i
                  end
      # rubocop:enable Lint/AssignmentInCondition
    end

    def set_author_names_caches(*)
      self.author_names_string_cache = make_author_names_string_cache
    end

    def make_author_names_string_cache
      author_names.map(&:name).join('; ').strip
    end
end
