# frozen_string_literal: true

class Institution < ApplicationRecord
  include Trackable

  # From https://stackoverflow.com/a/13653180
  UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/
  GRSCICOLL_IDENTIFIER_REGEX = %r{\A(institution|collection)/#{UUID_REGEX}\Z}
  GRSCICOLL_BASE_URL = "https://www.gbif.org/grscicoll/"

  NAME_MAX_LENGTH = 250
  ABBREVIATION_MAX_LENGTH = 10

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :abbreviation, presence: true, uniqueness: { case_sensitive: true },
    length: { maximum: ABBREVIATION_MAX_LENGTH }
  validates :grscicoll_identifier, format: { with: GRSCICOLL_IDENTIFIER_REGEX, allow_nil: true }

  has_paper_trail
  strip_attributes only: [:grscicoll_identifier]
  trackable parameters: proc { { abbreviation: abbreviation } }
end
