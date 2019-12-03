module Taxa
  class CheckIfInDatabaseResults
    include Service

    # Check runtime since this is shown on all catalog pages (logged-in users only).
    WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.1.seconds
    DATABASE_SCRIPTS_TO_CHECK = [
      DatabaseScripts::ExtantTaxaInFossilGenera,
      DatabaseScripts::ObsoleteCombinationsWithObsoleteCombinations,
      DatabaseScripts::PassThroughNamesWithTaxts,
      DatabaseScripts::SpeciesDisagreeingWithGenusRegardingSubfamily,
      DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingGenus,
      DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingSubfamily,
      DatabaseScripts::SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
      DatabaseScripts::SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
      DatabaseScripts::SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet
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
          next unless database_script_klass.taxon_in_results?(taxon)

          database_script = database_script_klass.new
          results << { message: database_script.issue_description, database_script: database_script }
        end
      end
  end
end
