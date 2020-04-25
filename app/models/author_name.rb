# frozen_string_literal: true

class AuthorName < ApplicationRecord
  include Trackable

  belongs_to :author

  has_many :reference_author_names, dependent: :restrict_with_error
  has_many :references, through: :reference_author_names, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: true }

  before_destroy :ensure_not_authors_only_author_name
  after_update :invalidate_reference_caches

  has_paper_trail
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

    def invalidate_reference_caches
      references.reload.find_each do |reference|
        reference.refresh_author_names_cache
        References::Cache::Invalidate[reference]
      end
    end

    def name_parts
      @_name_parts ||= Authors::ExtractAuthorNameParts[name]
    end
end
