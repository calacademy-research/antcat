class Tooltip < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  validates :scope, :text, presence: true
  validates :key, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._:\-]+\z/,
      message: "can only contain alphanumeric characters and '.-_:'" }

  has_paper_trail
  tracked on: :mixin_create_activity_only, parameters: proc { { scope_and_key: "#{scope}.#{key}" } }
end
