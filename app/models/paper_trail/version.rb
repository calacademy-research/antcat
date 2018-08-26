module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    include FilterableWhere
    include PrimitiveSearch

    belongs_to :change

    scope :without_user_versions, -> { where.not(item_type: "User") }

    has_primitive_search where: ->(search_type) { <<-SQL.squish }
      object #{search_type} :q OR object_changes #{search_type} :q
    SQL

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
