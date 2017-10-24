class Institution < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: true

  has_paper_trail
end
