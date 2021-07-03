# frozen_string_literal: true

class AuthorName < ApplicationRecord
  include Trackable

  NAME_MIN_LENGTH = 2
  # TODO: Probably do not allow Unicode Marks once records have been fixed.
  VALID_CHARACTERS_REGEX = /\A[ ',.\-\p{L}\p{M}]+\z/ # {L} = Unicode Letter; {M} = Unicode Mark.

  belongs_to :author

  has_many :reference_author_names, dependent: :restrict_with_error
  has_many :references, through: :reference_author_names, dependent: :restrict_with_error

  validates :name, presence: true, length: { minimum: NAME_MIN_LENGTH }, uniqueness: { case_sensitive: true },
    format: { with: VALID_CHARACTERS_REGEX, message: "contains unsupported characters" }
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

    def invalidate_reference_caches
      references.reload.find_each do |reference|
        reference.refresh_author_names_cache!
        reference.refresh_key_with_suffixed_year_cache!
        References::Cache::Invalidate[reference]
      end
    end

    def name_parts
      @_name_parts ||= Authors::ExtractAuthorNameParts[name]
    end
end
