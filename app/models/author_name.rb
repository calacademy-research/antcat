class AuthorName < ApplicationRecord
  include Trackable

  belongs_to :author

  has_many :reference_author_names
  has_many :references, through: :reference_author_names, dependent: :restrict_with_error

  validates :author, :name, presence: true
  validates :name, uniqueness: true

  before_destroy :ensure_not_authors_only_author_name
  after_update :invalidate_reference_caches!

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  trackable

  # TODO: Store in db?
  def last_name
    name_parts[:last]
  end

  # TODO: Store in db?
  def first_name_and_initials
    name_parts[:first_and_initials]
  end

  private

    def ensure_not_authors_only_author_name
      return if author.names.count > 1
      throw :abort
    end

    def invalidate_reference_caches!
      references.reload.find_each do |reference|
        reference.refresh_author_names_caches
        reference.invalidate_caches
      end
    end

    def name_parts
      @name_parts ||= Parsers::AuthorParser.get_name_parts name
    end
end
