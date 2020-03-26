# frozen_string_literal: true

require_dependency 'database_script'

module DatabaseScripts
  class DatabaseTestScript < DatabaseScript
    def results
      Reference.all
    end
  end
end
