# TODO avoid `require`.

require_dependency 'references/reference_has_document'
require_dependency 'references/reference_search'
require_dependency 'references/reference_utility'
require_dependency 'references/reference_workflow'

class Reference < ApplicationRecord
  include UndoTracker
  include ReferenceComparable
  include Feed::Trackable

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

  has_paper_trail meta: { change_id: :get_current_change_id }
  tracked parameters: ->(reference) do { name: reference.decorate.keey } end

  def self.requires_title
    true
  end

  # TODO make it more obvious which cache (also `set_cache`).
  def invalidate_cache
    ReferenceFormatterCache.invalidate self
  end

  def set_cache value, field
    ReferenceFormatterCache.set self, value, field
  end

  # TODO remove in favor of just using `principal_author_last_name`?
  # TODO it looks like `ReferenceMatcher` and `ReferenceComparable`
  # are the ones calling this.
  def author
    $stdout.puts "Reference#author".red
    principal_author_last_name
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
    duplicates = DuplicateMatcher.new.match self
    return unless duplicates.present?

    duplicate = Reference.find duplicates.first[:match].id
    errors.add :base, "This may be a duplicate of #{duplicate.decorate.formatted} #{duplicate.id}.<br>To save, click \"Save Anyway\"".html_safe
    true
  end

  def self.approve_all
    count = Reference.unreviewed.count
    Feed::Activity.without_tracking { Reference.unreviewed.find_each &:approve }
    Feed::Activity.create_activity :approve_all_references, count: count
  end

  # TODO merge into Workflow
  # Only for .approve_all, which approves all unreviewed
  # references of any state (which Workflow doesn't allow).
  def approve
    self.review_state = "reviewed"
    save!
    Feed::Activity.with_tracking { create_activity :finish_reviewing }
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

  private
    def check_not_referenced
      return unless has_any_references?

      # TODO list which items
      errors.add :base, "This reference can't be deleted, as there are other references to it."
      false
    end

    def check_not_nested
      if nestees.exists?
        errors.add :base, "This reference can't be deleted because it's nested in #{nestees.first.id}"
        return false
      end
      true
    end

    # TODO duplicates `CleanNewlines`?
    def strip_text_fields
      [:title, :public_notes, :editor_notes, :taxonomic_notes, :citation].each do |field|
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

    # Expensive method
    def reference_references return_true_or_false: false
      return_early = return_true_or_false

      references = []
      Taxt::TAXT_FIELDS.each do |klass, fields|
        klass.send(:all).find_each do |record|
          fields.each do |field|
            next unless record[field]
            if record[field] =~ /{ref #{id}}/
              references << table_ref(klass.table_name, record.id, field)
              return true if return_early
            end
          end
        end
      end

      Citation.where(reference: self).find_each do |record|
        references << table_ref(Citation.table_name, record.id, :reference_id)
        return true if return_early
      end

      nestees.find_each do |record|
        references << table_ref('references', record.id, :nesting_reference_id)
        return true if return_early
      end
      return false if return_early
      references
    end

    # Note: different order as compared to other `table_ref`s.
    def table_ref table, id, field
      { table: table, id: id, field: field }
    end

    def has_any_references?
      reference_references return_true_or_false: true
    end

    # TODO remove polymorphism unless it's used anywhere else.
    class DuplicateMatcher < ReferenceMatcher
      def min_similarity
        0.5
      end
    end
end
