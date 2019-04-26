class Institution < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: true

  has_paper_trail
  trackable parameters: proc { { abbreviation: abbreviation } }
end
