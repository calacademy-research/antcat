module Taxa
  class DatabaseScriptSoftValidationWarnings
    include Service

    # Check runtime since this is shown on all catalog pages (logged-in users only).
    WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.2.seconds
    DATABASE_SCRIPTS_TO_CHECK = [
      DatabaseScripts::ExtantTaxaInFossilGenera,
      DatabaseScripts::ObsoleteCombinationsWithObsoleteCombinations,
      DatabaseScripts::PassThroughNamesWithTaxts,
      DatabaseScripts::ReplacementNamesUsedForMoreThanOneTaxon,
      DatabaseScripts::SpeciesDisagreeingWithGenusRegardingSubfamily,
      DatabaseScripts::SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
      DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingGenus,
      DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingSubfamily,
      DatabaseScripts::SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
      DatabaseScripts::SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet,
      DatabaseScripts::ValidSubspeciesInInvalidSpecies
    ]

    def initialize taxon
      @taxon = taxon
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

      attr_reader :taxon

      def database_scripts_results
        DATABASE_SCRIPTS_TO_CHECK.each_with_object([]) do |database_script_klass, results|
          next unless database_script_klass.record_in_results?(taxon)

          database_script = database_script_klass.new
          results << { message: database_script.issue_description, database_script: database_script }
        end
      end
  end
end
