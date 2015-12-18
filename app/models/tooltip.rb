class Tooltip < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  default_scope { order(:key) }
  scope :enabled, -> { where(enabled: true) }

  scope :enabled_selectors, -> do
    enabled.where(selector_enabled: true).where.not(selector: "")
  end

  validates_uniqueness_of :key
end
