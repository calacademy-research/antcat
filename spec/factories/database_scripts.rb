# frozen_string_literal: true

module DatabaseScripts
  class DatabaseTestScript < DatabaseScript
    def results
      Reference.all
    end
  end
end
