# frozen_string_literal: true

# Predicts the masculine, feminine and neuter spellings of a species-group epithet that is an adjective or a
# participle, e.g. "crassispina" => { "masculine" => "crassispinus", "feminine" => "crassispina", "neuter" => "crassispinum" }.
#
# Ported from TaxonWorks, so that AntCat proposes the same spellings TaxonWorks shows:
# `Utilities::Nomenclature.predict_three_forms` (lib/utilities/nomenclature.rb) and `LATIN_ADJECTIVES`
# (config/initializers/constants/model/taxon_names.rb), SpeciesFileGroup/taxonworks, development branch 5dea15e,
# 2026-11-12. Copyright (c) 2016 Species File Group, MIT License:
# https://github.com/SpeciesFileGroup/taxonworks/blob/development/LICENSE.txt
#
# It assumes the epithet is an adjective or a participle. It cannot tell a noun from an adjective: the noun "trochis"
# would get the neuter "troche". Use it only for protonyms whose part of speech says the name is changeable.
module Protonyms
  class PredictGenderEpithets
    include Service

    # Irregular adjectives, checked before the ending rules (TaxonWorks' `LATIN_ADJECTIVES`).
    IRREGULAR_ADJECTIVES = {
      'acris' => %w[acer acris acre],
      'acre' => %w[acer acris acre],
      'acutius' => %w[acutior acutior acutius],
      'aequalius' => %w[aequalior aequalior aequalius],
      'afer' => %w[afer afra afrum],
      'alacris' => %w[alacer alacris alacre],
      'alacre' => %w[alacer alacris alacre],
      'alboater' => %w[alboater alboatra alboatrum],
      'alboatra' => %w[alboater alboatra alboatrum],
      'alboatrum' => %w[alboater alboatra alboatrum],
      'alter' => %w[alter altera alterum],
      'altera' => %w[alter altera alterum],
      'alterum' => %w[alter altera alterum],
      'angustius' => %w[angustior angustior angustius],
      'asper' => %w[asper aspera asperum],
      'aspera' => %w[asper aspera asperum],
      'asperum' => %w[asper aspera asperum],
      'atra' => %w[ater atra atrum],
      'atrum' => %w[ater atra atrum],
      'atrius' => %w[atrior atrior atrius],
      'brevius' => %w[brevior brevior brevius],
      'celeber' => %w[celeber celebris celebre],
      'celebris' => %w[celeber celebris celebre],
      'celebre' => %w[celeber celebris celebre],
      'celer' => %w[celer celeris celere],
      'celeris' => %w[celer celeris celere],
      'celere' => %w[celer celeris celere],
      'december' => %w[december decembris decembre],
      'decembris' => %w[december decembris decembre],
      'decembre' => %w[december decembris decembre],
      'decimaquartus' => %w[decimaquartus decimaquarta decimaquartum],
      'decimaquarta' => %w[decimaquartus decimaquarta decimaquartum],
      'decimaquartum' => %w[decimaquartus decimaquarta decimaquartum],
      'dementius' => %w[dementior dementior dementius],
      'dexter' => %w[dexter dextra dextrum],
      'dextra' => %w[dexter dextra dextrum],
      'dextrum' => %w[dexter dextra dextrum],
      'dilutius' => %w[dilutior dilutior dilutius],
      'egentius' => %w[egentior egentior egentius],
      'elatius' => %w[elatior elatior elatius],
      'excelsius' => %w[excelsior excelsior excelsius],
      'exter' => %w[exter extera exterum],
      'extera' => %w[exter extera exterum],
      'exterum' => %w[exter extera exterum],
      'flagellifer' => %w[flagellifer flagellifra flagellifrum],
      'flexius' => %w[flexior flexior flexius],
      'fortius' => %w[fortior fortior fortius],
      'gibber' => %w[gibber gibbera gibberum],
      'gibbera' => %w[gibber gibbera gibberum],
      'gibberum' => %w[gibber gibbera gibberum],
      'gracilius' => %w[gracilior gracilior gracilius],
      'humilius' => %w[humilior humilior humilius],
      'inferius' => %w[inferior inferior inferius],
      'ingentius' => %w[ingentior ingentior ingentius],
      'insignius' => %w[insignior insignior insignius],
      'interius' => %w[interior interior interius],
      'laevius' => %w[laevior laevior laevius],
      'latius' => %w[latior latior latius],
      'lepidius' => %w[lepidior lepidior lepidius],
      'liber' => %w[liber libera liberum],
      'libera' => %w[liber libera liberum],
      'liberum' => %w[liber libera liberum],
      'macer' => %w[macer macra macrum],
      'macra' => %w[macer macra macrum],
      'macrum' => %w[macer macra macrum],
      'maius' => %w[maior maior maius],
      'majus' => %w[major major majus],
      'metrius' => %w[metrior metrior metrius],
      'minus' => %w[minor minor minus],
      'minutius' => %w[minutior minutior minutius],
      'mirus' => %w[mirus mira mirum],
      'mira' => %w[mirus mira mirum],
      'mirum' => %w[mirus mira mirum],
      'miser' => %w[miser misera miserum],
      'misera' => %w[miser misera miserum],
      'miserum' => %w[miser misera miserum],
      'missius' => %w[missior missior missius],
      'mutius' => %w[mutior mutior mutius],
      'nigrius' => %w[nigrior nigrior nigrius],
      'notius' => %w[notior notior notius],
      'novembris' => %w[november novembris novembre],
      'novembre' => %w[november novembris novembre],
      'nudius' => %w[nudior nudior nudius],
      'obscurius' => %w[obscurior obscurior obscurius],
      'obtusius' => %w[obtusior obtusior obtusius],
      'octobris' => %w[october octobris octobre],
      'octobre' => %w[october octobris octobre],
      'orientalius' => %w[orientalior orientalior orientalius],
      'pallidius' => %w[pallidior pallidior pallidius],
      'perpulcher' => %w[perpulcher perpulchra perpulchrum],
      'perpulchra' => %w[perpulcher perpulchra perpulchrum],
      'perpulchrum' => %w[perpulcher perpulchra perpulchrum],
      'plenater' => %w[plenater plenatra plenatrum],
      'plenatra' => %w[plenater plenatra plenatrum],
      'plenatrum' => %w[plenater plenatra plenatrum],
      'posterius' => %w[posterior posterior posterius],
      'praestantius' => %w[praestantior praestantior praestantius],
      'praetener' => %w[praetener praetenera praetenerum],
      'praetenera' => %w[praetener praetenera praetenerum],
      'praetenerum' => %w[praetener praetenera praetenerum],
      'propius' => %w[propior propior propius],
      'pulcher' => %w[pulcher pulchra pulchrum],
      'pulchra' => %w[pulcher pulchra pulchrum],
      'pulchrum' => %w[pulcher pulchra pulchrum],
      'rotundius' => %w[rotundior rotundior rotundius],
      'sacer' => %w[sacer sacra sacrum],
      'sacra' => %w[sacer sacra sacrum],
      'sacrum' => %w[sacer sacra sacrum],
      'saluber' => %w[saluber salubris salubre],
      'salubris' => %w[saluber salubris salubre],
      'salubre' => %w[saluber salubris salubre],
      'semiater' => %w[semiater semiatra semiatrum],
      'semiatra' => %w[semiater semiatra semiatrum],
      'semiatrum' => %w[semiater semiatra semiatrum],
      'septembris' => %w[september septembris septembre],
      'septembre' => %w[september septembris septembre],
      'similius' => %w[similior similior similius],
      'sinister' => %w[sinister sinistra sinistrum],
      'sinistra' => %w[sinister sinistra sinistrum],
      'sinistrum' => %w[sinister sinistra sinistrum],
      'soporifer' => %w[soporifer soporifra soporifrum],
      'sordidius' => %w[sordidior sordidior sordidius],
      'subpulchra' => %w[subpulcher subpulchra subpulchrum],
      'superius' => %w[superior superior superius],
      'tener' => %w[tener tenera tenerum],
      'tenera' => %w[tener tenera tenerum],
      'tenerum' => %w[tener tenera tenerum],
      'turpius' => %w[turpior turpior turpius],
      'ulterius' => %w[ulterior ulterior ulterius],
      'vilius' => %w[vilior vilior vilius],
      'vetus' => %w[vetus vetus vetus]
    }.freeze

    # -iger ("bearing") compounds whose stem ends in n. TaxonWorks' /(niger|integer)$/ rule takes them for niger
    # ("black") and gives cornigra, spinigra, lanigra; the Latin keeps the e. Every such stem among AntCat's
    # epithets (November 2026). A deliberate departure from TaxonWorks.
    IGER_COMPOUND = /(corn|lan|spin|pinn|crin|ign|con|dolon)(iger|igera|igerum)$/

    attr_private_initialize :epithet

    def call
      return if epithet.blank?

      masculine, feminine, neuter = IRREGULAR_ADJECTIVES[epithet] || forms_by_ending
      { 'masculine' => masculine, 'feminine' => feminine, 'neuter' => neuter }
    end

    private

      # Same rules, in the same order, as TaxonWorks' `predict_three_forms`, except -iger compounds (above).
      def forms_by_ending
        name = epithet
        if (match = IGER_COMPOUND.match(name))
          stem = "#{name[0...match.begin(2)]}iger"
          return [stem, "#{stem}a", "#{stem}um"]
        end

        case name
        when /(color|coloris)$/      then [name, name, name]
        when /is$/                   then [name, name, "#{name[0..-3]}e"]
        when /e$/                    then ["#{name[0..-2]}is", "#{name[0..-2]}is", name]
        when /us$/                   then [name, "#{name[0..-3]}a", "#{name[0..-3]}um"]
        when /(niger|integer)$/      then [name, "#{name[0..-3]}ra", "#{name[0..-3]}rum"]
        when /(fer|ger)$/            then [name, "#{name}a", "#{name}um"]
        when /er$/                   then [name, "#{name[0..-3]}ra", "#{name[0..-3]}rum"]
        when /(ferum|gerum)$/        then [name[0..-3], "#{name[0..-3]}a", name]
        when /(gera|fera)$/          then [name[0..-2], name, "#{name[0..-2]}um"]
        when /(brum|frum|grum)$/     then ["#{name[0..-4]}er", "#{name[0..-3]}a", name]
        when /(bra|gra|fra)$/        then ["#{name[0..-3]}er", name, "#{name[0..-2]}um"]
        when /um$/                   then ["#{name[0..-3]}us", "#{name[0..-3]}a", name]
        when /a$/                    then ["#{name[0..-2]}us", name, "#{name[0..-2]}um"]
        when /(nor|ior|jor)$/        then [name, name, "#{name[0..-3]}us"]
        else                              [name, name, name]
        end
      end
  end
end
