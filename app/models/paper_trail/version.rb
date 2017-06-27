# Per http://stackoverflow.com/questions/35595171/why-do-methods-defined-in-an-initializer-intermittently-raise-a-not-defined-er

# Confirm that autoloading works after editing this file by going to
# the changes page and look for "<username and link> deleted <taxon>".
# Edit any autoloaded file and refresh the page. It should not say
# "Someone deleted <taxon>" this time.

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    include FilterableWhere

    attr_accessible :change_id

    scope :without_user_versions, -> { where.not(item_type: "User") }

    scope :search_objects, ->(search_params) do
      search_type = search_params[:search_type].presence || "LIKE"
      raise unless search_type.in? ["LIKE", "REGEXP"]

      q = search_params[:q]
      q = "%#{q}%" if search_type == "LIKE"

      where(<<-SQL.squish, q: q)
        object #{search_type} :q OR object_changes #{search_type} :q
      SQL
    end

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
