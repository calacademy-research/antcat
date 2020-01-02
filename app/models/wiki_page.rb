class WikiPage < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  TITLE_MAX_LENGTH = 70

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }, uniqueness: true
  validates :content, presence: true

  has_paper_trail
  trackable parameters: proc { { title: title } }
end
