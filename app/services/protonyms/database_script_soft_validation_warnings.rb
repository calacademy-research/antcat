module Protonyms
  class DatabaseScriptSoftValidationWarnings
    include Service

    # Check runtime since this is shown on all catalog pages (logged-in users only).
    WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.2.seconds
    DATABASE_SCRIPTS_TO_CHECK = [
      DatabaseScripts::FossilProtonymsWithNonFossilTaxa,
      DatabaseScripts::NonFossilProtonymsWithFossilTaxa,
      DatabaseScripts::OrphanedProtonyms,
      DatabaseScripts::ProtonymsWithDuplicatedTaxa,
      DatabaseScripts::ProtonymsWithMoreThanOneOriginalCombination,
      DatabaseScripts::ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
    ]

    def initialize protonym
      @protonym = protonym
    end

    def call
      start = Time.current

      results = database_scripts_results

      render_duration = Time.current - start
      if render_duration > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
        results << { message: "Script runtime: #{render_duration} seconds" }
      end

      results
    end

    private

      attr_reader :protonym

      def database_scripts_results
        DATABASE_SCRIPTS_TO_CHECK.each_with_object([]) do |database_script_klass, results|
          next unless database_script_klass.record_in_results?(protonym)

          database_script = database_script_klass.new
          results << { message: database_script.issue_description, database_script: database_script }
        end
      end
  end
end
