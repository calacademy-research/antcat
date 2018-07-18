# TODO avoid `require`.
# TODO exclude caches from PaperTrail.

require_dependency 'references/reference_has_document'
require_dependency 'references/reference_workflow'

class Reference < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  # Virtual attributes used in `RefrencesController`.
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
  has_many :described_taxa, through: :protonyms, source: :taxon

  validates :title, presence: true, if: -> { self.class.requires_title }

  before_validation :set_year_from_citation_year
  before_save :set_author_names_caches
  before_destroy :check_not_referenced, :check_not_nested

  scope :includes_document, -> { includes(:document) }
  scope :latest_additions, -> { order(created_at: :desc) }
  scope :latest_changes, -> { order(updated_at: :desc) }
  scope :no_missing, -> { where.not(type: "MissingReference") }
  scope :order_by_author_names_and_year, -> { order(:author_names_string_cache, :citation_year) }
  scope :sorted_by_principal_author_last_name, -> { order(:principal_author_last_name_cache) }
  scope :unreviewed, -> { where.not(review_state: "reviewed") }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:editor_notes, :public_notes, :taxonomic_notes, :title,
    :citation, :date, :citation_year, :series_volume_issue, :pagination,
    :pages_in, :doi, :reason_missing, :review_state], replace_newlines: true
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
    # HACK quick fix to make the year searchable as a keyword.
    text    :year_as_string do year.to_s if year end
    text    :citation
    text    :editor_notes
    text    :public_notes
    text    :taxonomic_notes
    string  :citation_year
    string  :author_names_string
  end

  def self.requires_title
    true
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

  def author_names_string=(string)
    self.author_names_string_cache = string
  end

  # TODO we should probably have `#year` [int] and something
  # like `#non_standard_year` [string] instead of this +
  # `#year` + `#citation_year`.
  # TODO what is this used for?
  def short_citation_year
    return "[no year]" unless citation_year.present?
    citation_year.gsub %r{ .*$}, ''
  end

  # TODO does this duplicate `set_author_names_caches`?
  # There's also `#author_names_string=` which sets `#author_names_string_cache`.
  def refresh_author_names_caches(*)
    string, principal_author_last_name = make_author_names_caches
    # TODO only update once.
    update_attribute :author_names_string_cache, string
    update_attribute :principal_author_last_name_cache, principal_author_last_name
  end

  def parse_author_names_and_suffix author_names_string
    author_names_and_suffix = AuthorName.import_author_names_string author_names_string.dup
    if author_names_and_suffix[:author_names].empty? && author_names_string.present?
      errors.add :author_names_string, "couldn't be parsed."
      self.author_names_string = author_names_string
      raise ActiveRecord::RecordInvalid, self
    end
    author_names_and_suffix
  end

  def check_for_duplicate
    duplicates = References::MatchReferences[self, min_similarity: 0.5]
    return unless duplicates.present?

    duplicate = Reference.find duplicates.first[:match].id
    errors.add :base, "This may be a duplicate of #{duplicate.decorate.formatted} #{duplicate.id}.<br>To save, click \"Save Anyway\"".html_safe
    true
  end

  # TODO merge into Workflow. Only used for `.approve_all`,
  # which approves all unreviewed references of any state (which Workflow doesn't allow).
  def approve
    self.review_state = "reviewed"
    save!
    Feed.with_tracking { create_activity :finish_reviewing }
  end

  # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978".
  #
  # Stupid name because useful.
  # "key" is impossible to grep for, and a word with too many meanings.
  # Variations of "last author names" or "ref_key" are doomed to fail.
  # So, "keey". Obviously, do not show this spelling to users or use
  # it in filesnames or the database.
  #
  # Note: `references.author_names_string_cache` may also be useful?
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
    else
      string = names[0..-2].join ', '
      string << " & " << names[-1]
    end
  end

  # TODO find proper name.
  def year_or_no_year
    return "[no year]" if year.blank?
    year.to_s
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

    # TODO does this duplicate `refresh_author_names_caches`?
    def set_author_names_caches(*)
      self.author_names_string_cache, self.principal_author_last_name_cache = make_author_names_caches
    end

    def make_author_names_caches
      string = author_names.map(&:name).join('; ')
      string << author_names_suffix if author_names_suffix.present?
      first_author_name = author_names.first
      last_name = first_author_name && first_author_name.last_name

      [string, last_name]
    end
end
