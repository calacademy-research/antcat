class Tooltip < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Feed::Trackable

  default_scope { order(:key) } # TODO probably remove, default scope are possibly evil.

  validates :key, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._:\-]+\z/,
      message: "can only contain alphanumeric characters and '.-_:'" }

  scope :enabled_keys, -> { where(key_enabled: true) }
  scope :enabled_selectors, -> do
    where(selector_enabled: true).where.not(selector: "")
  end

  has_paper_trail
  tracked on: :all, parameters: ->(tooltip) do
    { scope_and_key: "#{tooltip.scope}.#{tooltip.key}" }
  end

  def key_disabled?
    !key_enabled?
  end
end
