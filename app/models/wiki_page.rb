class WikiPage < ApplicationRecord
  include Trackable

  TITLE_MAX_LENGTH = 70

  PERMANENT_IDENTIFIERS = [
    NEW_CONTRIBUTORS_HELP_PAGE = 'new_contributors_help_page'
  ]

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }, uniqueness: { case_sensitive: true }
  validates :content, presence: true

  has_paper_trail
  trackable parameters: proc { { title: title } }
end
