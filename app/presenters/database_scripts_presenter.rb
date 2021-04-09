# frozen_string_literal: true

class DatabaseScriptsPresenter
  def tallied_tags
    @_tallied_tags ||= DatabaseScript.all.map(&:tags).flatten.tally.sort_by(&:first)
  end
end
