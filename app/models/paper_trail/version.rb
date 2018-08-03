# Per http://stackoverflow.com/questions/35595171/why-do-methods-defined-in-an-initializer-intermittently-raise-a-not-defined-er

# Confirm that autoloading works after editing this file by going to
# the changes page and look for "<username and link> deleted <taxon>".
# Edit any autoloaded file and refresh the page. It should not say
# "Someone deleted <taxon>" this time.

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
