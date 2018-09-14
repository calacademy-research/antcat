class Tooltip < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  validates :key, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._:\-]+\z/,
      message: "can only contain alphanumeric characters and '.-_:'" }

  scope :enabled_selectors, -> do
    where(selector_enabled: true).where.not(selector: "")
  end

  has_paper_trail
  tracked on: :all, parameters: proc { { scope_and_key: "#{scope}.#{key}" } }

  def key_disabled?
    !key_enabled?
  end
end
