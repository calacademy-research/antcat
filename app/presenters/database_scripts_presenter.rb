# frozen_string_literal: true

# The tags of all database scripts with their counts, for the filter of /database_scripts.
class DatabaseScriptsPresenter
  def tallied_tags
    @_tallied_tags ||= DatabaseScript.all.map(&:tags).flatten.tally.sort_by(&:first)
  end
end
