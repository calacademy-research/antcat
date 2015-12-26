class Tooltip < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  default_scope { order(:key) }
  scope :enabled_keys, -> { where(key_enabled: true) }

  scope :enabled_selectors, -> do
    where(selector_enabled: true).where.not(selector: "")
  end

  validates :key, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._:\-]+\z/,
      message: "can only contain alphanumeric characters and '.-_:'" }

  def key_disabled?
    !key_enabled?
  end
end
