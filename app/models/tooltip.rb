class Tooltip < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  validates :scope, :text, presence: true
  validates :key, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._:\-]+\z/, message: "can only contain alphanumeric characters and '.-_:'" }

  has_paper_trail
  trackable parameters: proc { { scope_and_key: "#{scope}.#{key}" } }
end
