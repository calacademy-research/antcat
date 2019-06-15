module Taxa
  class CheckIfInDatabaseResults
    include Service

    WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.1.seconds
    DATABASE_SCRIPTS_TO_CHECK = [
      DatabaseScripts::ExtantTaxaInFossilGenera,
      DatabaseScripts::JuniorSynonymsListedAsAnotherTaxonsSenior,
      DatabaseScripts::PassThroughNamesWithTaxts,
      DatabaseScripts::SubspeciesWithoutSpecies,
      DatabaseScripts::TaxaReferencingNonExistingTaxa,
      DatabaseScripts::TaxaWithBothJuniorAndSeniorSynonyms,
      DatabaseScripts::TaxaWithMoreThanOneSeniorSynonym,
      DatabaseScripts::ValidTaxaListedAsAnotherTaxonsJuniorSynonym
    ]

    def initialize taxon
      @taxon = taxon
      @results = []
    end

    def call
      check_if_in_database_scripts_results
      results
    end

    private

      attr_reader :taxon, :results

      def check_if_in_database_scripts_results
        start = Time.current

        DATABASE_SCRIPTS_TO_CHECK.each do |database_script_klass|
          next unless database_script_klass.taxon_in_results?(taxon)

          database_script = database_script_klass.new
          results << { message: database_script.issue_description, database_script: database_script }
        end

        render_duration = Time.current - start
        if render_duration > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
          results << { message: "Script runtime: #{render_duration} seconds" }
        end
      end
  end
end
