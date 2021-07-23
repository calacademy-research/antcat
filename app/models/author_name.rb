# frozen_string_literal: true

class AuthorName < ApplicationRecord
  include Trackable

  NAME_MIN_LENGTH = 2
  # TODO: Probably do not allow Unicode Marks once records have been fixed.
  VALID_CHARACTERS_REGEX = /\A[ ',.\-\p{L}\p{M}]+\z/ # {L} = Unicode Letter; {M} = Unicode Mark.
  ALLOWED_SUFFIXES = %w[Jr. Sr. II III]

  belongs_to :author

  has_many :reference_author_names, dependent: :restrict_with_error
  has_many :references, through: :reference_author_names, dependent: :restrict_with_error

  validates :name, presence: true, length: { minimum: NAME_MIN_LENGTH }, uniqueness: { case_sensitive: true },
    format: { with: VALID_CHARACTERS_REGEX, message: "contains unsupported characters" }
  # TODO: Remove `on: :create` (or just squish the string) once records have been fixed.
  validates :name, format: { without: /  /, message: "cannot contain consecutive spaces" }, on: :create
  validates :name, format: { without: /,[^ ]/, message: "cannot contain commas not followed by a space" }
  validate :validate_commas_and_suffixes, if: -> { name.present? }
  after_update :invalidate_reference_caches

  has_paper_trail
  trackable

  def last_name
    last, _ = name_parts
    last
  end

  def first_name_and_initials
    _, first = name_parts
    first
  end

  private

    def validate_commas_and_suffixes
      return if (name.split(', ') - ALLOWED_SUFFIXES).size < 3
      errors.add :name, "can only contain a single comma (excluding allowed suffixes: #{ALLOWED_SUFFIXES.join(', ')})"
    end

    def invalidate_reference_caches
      references.reload.find_each do |reference|
        reference.refresh_author_names_cache!
        reference.refresh_key_with_suffixed_year_cache!
        References::Cache::Invalidate[reference]
      end
    end

    def name_parts
      @_name_parts ||= name.split(', ', 2)
    end
end
