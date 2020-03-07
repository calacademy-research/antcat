class Institution < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  NAME_MAX_LENGTH = 200
  ABBREVIATION_MAX_LENGTH = 10

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :abbreviation, presence: true, uniqueness: { case_sensitive: true }, length: { maximum: ABBREVIATION_MAX_LENGTH }

  has_paper_trail
  trackable parameters: proc { { abbreviation: abbreviation } }
end
