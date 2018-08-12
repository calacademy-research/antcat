class Role < ApplicationRecord
  ROLES = [
    EDITOR = "editor",
    SUPERADMIN = "superadmin"
  ]

  has_and_belongs_to_many :users, join_table: :users_roles

  validates :name, inclusion: { in: ROLES }
end
