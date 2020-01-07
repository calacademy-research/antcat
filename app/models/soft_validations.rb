class SoftValidations
  WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.2.seconds

  # These scripts do not 100% belong here since scripts are injected to avoid coupling.
  TAXA_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::CurrentValidTaxonChains,
    DatabaseScripts::ExtantTaxaInFossilGenera,
    DatabaseScripts::FossilTaxaWithNonFossilProtonyms,
    DatabaseScripts::NonFossilTaxaWithFossilProtonyms,
    DatabaseScripts::NonOriginalCombinationsWithSameNameAsItsProtonym,
    DatabaseScripts::NonValidTaxaWithACurrentValidTaxonThatIsNotValid,
    DatabaseScripts::NonValidTaxaWithJuniorSynonyms,
    DatabaseScripts::ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon,
    DatabaseScripts::ObsoleteCombinationsWithObsoleteCombinations,
    DatabaseScripts::ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym,
    DatabaseScripts::ObsoleteCombinationsWithVeryDifferentEpithets,
    DatabaseScripts::PassThroughNamesWithTaxts,
    DatabaseScripts::ReplacementNamesUsedForMoreThanOneTaxon,
    DatabaseScripts::SpeciesDisagreeingWithGenusRegardingSubfamily,
    DatabaseScripts::SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
    DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingGenus,
    DatabaseScripts::SubspeciesDisagreeingWithSpeciesRegardingSubfamily,
    DatabaseScripts::SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet,
    DatabaseScripts::SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet,
    DatabaseScripts::SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon,
    DatabaseScripts::TaxaWithNonModernCapitalization,
    DatabaseScripts::TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms,
    DatabaseScripts::TaxaWithUncommonTypeTaxts,
    DatabaseScripts::UnavailableUncategorizedTaxa,
    DatabaseScripts::ValidSubspeciesInInvalidSpecies
  ]
  PROTONYM_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::FossilProtonymsWithNonFossilTaxa,
    DatabaseScripts::NonFossilProtonymsWithFossilTaxa,
    DatabaseScripts::OrphanedProtonyms,
    DatabaseScripts::ProtonymsWithDuplicatedTaxa,
    DatabaseScripts::ProtonymsWithMoreThanOneOriginalCombination,
    DatabaseScripts::ProtonymsWithMoreThanOneSynonym,
    DatabaseScripts::ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems,
    DatabaseScripts::ProtonymsWithMoreThanOneValidTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithMoreThanOneTypeTaxon
  ]
  ALL_DATABASE_SCRIPTS_TO_CHECK = TAXA_DATABASE_SCRIPTS_TO_CHECK + PROTONYM_DATABASE_SCRIPTS_TO_CHECK

  def initialize record, database_script_klasses
    @record = record
    @database_script_klasses = database_script_klasses
  end

  def all
    @all ||= database_script_klasses.map do |database_script_klass|
      SoftValidation.run(record, database_script_klass)
    end
  end

  def failed
    @failed ||= all.select(&:failed?)
  end

  def failed?
    failed.present?
  end

  def total_runtime
    @total_runtime ||= all.map(&:runtime).sum
  end

  def warn_about_slow_runtime?
    total_runtime > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
  end

  private

    attr_reader :record, :database_script_klasses
end
