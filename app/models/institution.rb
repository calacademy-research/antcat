class Institution < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Trackable

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: true

  has_paper_trail
  tracked on: :mixin_create_activity_only, parameters: proc {
    { abbreviation: abbreviation }
  }
end
