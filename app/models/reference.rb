# TODO avoid `require`.
# TODO consider moving callbacks and validators to a concern.
# TODO exclude caches from PaperTrail.

require_dependency 'references/reference_has_document'
require_dependency 'references/reference_search'
require_dependency 'references/reference_workflow'

class Reference < ApplicationRecord
  include ReferenceComparable
  include RevisionsCanBeCompared
  include Trackable

  # Virtual attributes used in `RefrencesController`.
  attr_accessor :journal_name, :publisher_string

  attr_accessible :author_names, :author_names_suffix, :citation, :citation_year,
    :cite_code, :date, :document_attributes, :doi, :editor_notes, :journal_name,
    :nesting_reference_id, :pages_in, :pagination, :possess, :public_notes,
    :publisher_string, :review_state, :series_volume_issue, :taxonomic_notes,
    :title

  belongs_to :journal
  belongs_to :publisher

  has_many :reference_author_names, -> { order(:position) }
  has_many :author_names, -> { order('reference_author_names.position') },
           through: :reference_author_names,
           after_add: :refresh_author_names_caches,
           after_remove: :refresh_author_names_caches
  has_many :nestees, class_name: "Reference", foreign_key: "nesting_reference_id"

  validates :title, presence: true, if: -> { self.class.requires_title }

  before_validation :set_year_from_citation_year, :strip_text_fields
  before_save { CleanNewlines.clean_newlines self, :editor_notes, :public_notes, :taxonomic_notes, :title, :citation }
  before_save :set_author_names_caches
  before_destroy :check_not_referenced, :check_not_nested

  scope :sorted_by_principal_author_last_name, -> { order(:principal_author_last_name_cache) }
  scope :with_principal_author_last_name, ->(last_name) { where(principal_author_last_name_cache: last_name) }
  scope :unreviewed, -> { where.not(review_state: "reviewed") }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :mixin_create_activity_only, parameters: proc { { name: keey } }

  def self.requires_title
    true
  end

  def invalidate_caches
    ReferenceFormatterCache.invalidate self
  end

  def set_cache value, field
    ReferenceFormatterCache.set self, value, field
  end

  # TODO something. "_cache" vs not.
  # Looks like: "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y.".
  def author_names_string
    author_names_string_cache
  end

  def author_names_string=(string)
    self.author_names_string_cache = string
  end

  # Possibly only used for sorting. The principal author is decided
  # by generated all author name and picking the first, and that order
  # is presumably decided by `reference_author_names.position`.
  # Not sure if it would make sense to use this in any other way.
  def principal_author_last_name
    principal_author_last_name_cache
  end

  # TODO we should probably have #year [int] and something
  # like #non_standard_year [string] instead of this +
  # #year + #citation_year.
  # TODO what is this used for?
  def short_citation_year
    if citation_year.present?
      citation_year.gsub %r{ .*$}, ''
    else
      "[no year]"
    end
  end

  # update (including observed updates)
  # TODO does this duplicate `set_author_names_caches`?
  # There's also ` author_names_string=` which sets `author_names_string_cache`.
  def refresh_author_names_caches(*)
    string, principal_author_last_name = make_author_names_caches
    update_attribute :author_names_string_cache, string
    update_attribute :principal_author_last_name_cache, principal_author_last_name
  end

  # TODO move to a callback.
  # Called by controller to parse an input string for author names and suffix
  # Returns hash of parse result, or adds to the reference's errors and raises
  def parse_author_names_and_suffix author_names_string
    author_names_and_suffix = AuthorName.import_author_names_string author_names_string.dup
    if author_names_and_suffix[:author_names].empty? && author_names_string.present?
      errors.add :author_names_string, "couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
      self.author_names_string = author_names_string
      raise ActiveRecord::RecordInvalid.new self
    end
    author_names_and_suffix
  end

  def check_for_duplicate
    duplicates = ReferenceMatcher.new(min_similarity: 0.5).match self
    return unless duplicates.present?

    duplicate = Reference.find duplicates.first[:match].id
    errors.add :base, "This may be a duplicate of #{duplicate.decorate.formatted} #{duplicate.id}.<br>To save, click \"Save Anyway\"".html_safe
    true
  end

  def self.approve_all
    count = Reference.unreviewed.count
    Feed.without_tracking { Reference.unreviewed.find_each &:approve }
    Activity.create_without_trackable :approve_all_references, count: count
  end

  # TODO merge into Workflow
  # Only for .approve_all, which approves all unreviewed
  # references of any state (which Workflow doesn't allow).
  def approve
    self.review_state = "reviewed"
    save!
    Feed.with_tracking { create_activity :finish_reviewing }
  end

  def new_from_copy
    new_reference = self.class.new # Build correct type.

    # Type-specific fields.
    to_copy = case self
              when ArticleReference then [:series_volume_issue]
              when NestedReference  then [:pages_in, :nesting_reference_id]
              when UnknownReference then [:citation]
              else                       []
              end

    # Basic fields and notes.
    to_copy.concat [ :author_names_string,
                     :citation_year,
                     :title,
                     :pagination,
                     :public_notes,
                     :editor_notes,
                     :taxonomic_notes ]

    # The two virtual attributes.
    if is_a? BookReference
      new_reference.publisher_string = "#{publisher.place.name}: #{publisher.name}"
    end
    new_reference.journal_name = journal.name if is_a? ArticleReference

    copy_attributes_to new_reference, *to_copy
    new_reference
  end

  ### Methods currently in quarantine ###
  # Moved here from `ReferenceDecorator`, to be refactored/DRYed where possible.

  def key
    raise "use 'keey' (not a joke)"
  end

  # "THE KEEY" -- Stupid Name Because Useful(tm).
  #
  # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978"
  #
  # "key" is impossible to grep for, and a word with too many meanings.
  # Variations of "last author names" or "ref_key" are doomed to fail.
  # So, "keey". Obviously, do not show this spelling to users or use
  # it in filesnames or the database.
  #
  # Note: `references.author_names_string_cache` may also be useful?
  def keey
    authors_for_keey << ', ' << short_citation_year
  end

  # normal keey: "Bolton, 1885g"
  # this:        "Bolton, 1885"
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

  ### end quarantine ###

  def reference_references return_true_or_false: false
    References::WhatLinksHere.new(self, return_true_or_false: return_true_or_false).call
  end

  private
    def check_not_referenced
      return unless has_any_references?

      # TODO list which items
      errors.add :base, "This reference can't be deleted, as there are other references to it."
      false
    end

    def check_not_nested
      return unless nestees.exists?

      errors.add :base, "This reference can't be deleted because it's nested in #{nestees.first.id}"
      false
    end

    # TODO duplicates `CleanNewlines`?
    def strip_text_fields
      fields = [:title, :public_notes, :editor_notes, :taxonomic_notes, :citation]
      fields.each do |field|
        value = self[field]
        next unless value.present?
        value.gsub! /(\n|\r|\n\r|\r\n)/, ' '
        value.strip!
        value.squeeze! ' '
        self[field] = value
      end
    end

    def set_year_from_citation_year
      self.year = year_from_citation_year citation_year
    end

    def year_from_citation_year citation_year
      return if citation_year.blank? # Sets `self.year` to nil.

      if match = citation_year.match(/\["(\d{4})"\]/)
        match[1]
      else
        citation_year.to_i
      end
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

    def has_any_references?
      reference_references return_true_or_false: true
    end
end
