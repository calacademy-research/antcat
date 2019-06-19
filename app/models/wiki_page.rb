class WikiPage < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  validates :title, presence: true, length: { maximum: 70 }, uniqueness: true
  validates :content, presence: true

  has_paper_trail
  trackable parameters: proc { { title: title } }
end
