# frozen_string_literal: true

class DbScriptSoftValidations
  WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.2.seconds

  # These scripts do not 100% belong here since scripts are injected to avoid coupling.
  TAXA_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::CurrentTaxonChains,
    DatabaseScripts::ExtantTaxaInFossilGenera,
    DatabaseScripts::FossilTaxaWithNonFossilProtonyms,
    DatabaseScripts::GeneraWithNamesThatAreDifferentFromTheirProtonymsName,
    DatabaseScripts::NonFossilTaxaWithFossilProtonyms,
    DatabaseScripts::NonValidTaxaWithACurrentTaxonThatIsNotValid,
    DatabaseScripts::NonValidTaxaWithJuniorSynonyms,
    DatabaseScripts::ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon,
    DatabaseScripts::ObsoleteCombinationsWithObsoleteCombinations,
    DatabaseScripts::ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym,
    DatabaseScripts::ObsoleteCombinationsWithVeryDifferentEpithets,
    DatabaseScripts::ReplacementNamesUsedForMoreThanOneTaxon,
    DatabaseScripts::SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym,
    DatabaseScripts::SynonymGeneraWithSpeciesWithIncompatibleStatuses,
    DatabaseScripts::SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon,
    DatabaseScripts::SynonymSpeciesWithSubspeciesWithIncompatibleStatuses,
    DatabaseScripts::TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms,
    DatabaseScripts::ValidSubspeciesInInvalidSpecies,
    DatabaseScripts::ValidTaxaWithNonValidParents
  ]
  PROTONYM_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::FossilProtonymsWithNonFossilTaxa,
    DatabaseScripts::NonFossilProtonymsWithFossilTaxa,
    DatabaseScripts::OrphanedProtonyms,
    DatabaseScripts::ProtonymsWithDuplicatedTaxa,
    DatabaseScripts::ProtonymsWithMoreThanOneOriginalCombination,
    DatabaseScripts::ProtonymsWithMoreThanOneSpeciesInTheSameGenus,
    DatabaseScripts::ProtonymsWithMoreThanOneSynonym,
    DatabaseScripts::ProtonymsWithMoreThanOneValidTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithMoreThanOneCurrentTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithVeryDifferentEpithets
  ]
  ALL_DATABASE_SCRIPTS_TO_CHECK = TAXA_DATABASE_SCRIPTS_TO_CHECK + PROTONYM_DATABASE_SCRIPTS_TO_CHECK

  attr_private_initialize :record, :database_script_klasses

  def all
    @_all ||= database_script_klasses.map do |database_script_klass|
      DbScriptSoftValidation.run(record, database_script_klass)
    end
  end

  def failed
    @_failed ||= all.select(&:failed?)
  end

  # TODO: Check lazily.
  def failed?
    failed.present?
  end

  def total_runtime
    @_total_runtime ||= all.sum(&:runtime)
  end

  def warn_about_slow_runtime?
    total_runtime > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
  end
end
