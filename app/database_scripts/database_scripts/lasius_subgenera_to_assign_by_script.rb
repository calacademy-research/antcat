# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Style/ConditionalAssignment
# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/SafeNavigation
module DatabaseScripts
  class LasiusSubgeneraToAssignByScript < DatabaseScript
    TO_ASSIGN_RAW = {
      'Lasius' => %w[
        alienus
        austriacus
        balearicus
        bombycina
        brevipalpus
        brunneus
        casevitzi
        chinensis
        cinereus
        coloratus
        creticus
        cyperus
        emarginatus
        excavatus
        flavescens
        flavoniger
        grandis
        hayashi
        himalayanus
        hirsutus
        illyricus
        israelicus
        japonicus
        kabaki
        karpinisi
        koreanus
        kritikos
        lasioides
        lawarai
        longipalpus
        magnus
        maltaeus
        mauretanicus
        neglectus
        niger
        nigrescens
        obscuratus
        paralienus
        persicus
        piliferus
        platythorax
        precursor
        productus
        psammophilus
        sakagamii
        schaeferi
        schulzi
        sichuense
        silvaticus
        tapinomoides
        tebessae
        tunisius
        turcicus
        uzbeki
        vostochni
        wittmeri
        pallitarsis
        sitiens
        neoniger
        crypticus
        americanus
        xerophilus
        breviscapus
        gebaueri
      ],
      'Dendrolasius' => %w[
        buccatus
        capitatus
        fuji
        fuliginosus
        morisitai
        nipponensis
        orientalis
        spathepus
      ],
      'Cautolasius' => %w[
        alienoflavus
        elevatus
        fallax
        flavus
        myops
        nearcticus
        sonobei
        talpa
        brevicornis
      ],
      'Chthonolasius' => %w[
        aphidicola
        atopus
        balcanicus
        bicornis
        citrinus
        crinitus
        distinguendus
        hikosanus
        humilis
        jensi
        longiceps
        meridionalis
        minutus
        mixtus
        nemorivagus
        nevadensis
        przewalskii
        rabaudi
        sabularum
        speculiventris
        subumbratus
        tibialis
        umbratus
        vestitus
        viehmeyeri
      ],
      'Austrolasius' => %w[
        carniolicus
        reginae
      ],
      'Acanthomyops' => %w[
        arizonicus
        bureni
        californicus
        claviger
        colei
        coloradensis
        creightoni
        interjectus
        latipes
        mexicanus
        murphyi
        occidentalis
        plumopilosus
        pogonogynus
        pubescens
        subglaber
      ]
    }
    GENUS_NAME = 'Lasius'

    def statistics
      "Number of items: #{to_assign.size} (successful or not)".html_safe
    end

    def render
      as_table do |t|
        t.header 'Subgenus part of name', 'Target subgenus', 'Subgenus status',
          'Species name', 'Target species', 'Species status',
          'Current subgenus', 'Good to go?', 'Cannot assign because'
        t.rows(to_assign) do |(subgenus_part_of_name, species_name)|
          subgenus_name = "#{GENUS_NAME} (#{subgenus_part_of_name})"
          subgenus_candidates = Subgenus.where(name_cache: subgenus_name)
          subgenus_candidates_count = subgenus_candidates.count
          subgenus = if subgenus_candidates_count == 1
                       subgenus_candidates.first
                     end

          species_candidates = Species.where(name_cache: species_name)
          species_candidates_count = species_candidates.count
          species = if species_candidates_count == 1
                      species_candidates.first
                    end

          cannot_assign_because = []
          cannot_assign_because << "Found no subgenus with the name #{subgenus_name}" if subgenus_candidates_count == 0
          cannot_assign_because << "Found more than one subgenus: #{taxa_list(subgenus_candidates)}" if subgenus_candidates_count > 1
          cannot_assign_because << "Found no species with the name #{species_name}" if species_candidates_count == 0
          cannot_assign_because << "Found more than one species: #{taxa_list(species_candidates)}" if species_candidates_count > 1
          if species&.subgenus
            if subgenus_candidates_count == 1 && species.subgenus == subgenus
              cannot_assign_because << "Already done!"
            else
              cannot_assign_because << "Species is already assigned to a different subgenus"
            end
          end

          [
            subgenus_part_of_name,
            (CatalogFormatter.link_to_taxon(subgenus) if subgenus),
            (subgenus.status if subgenus),

            species_name,
            (CatalogFormatter.link_to_taxon(species) if species),
            (species.status if species),

            (CatalogFormatter.link_to_taxon(species.subgenus) if species&.subgenus),
            (cannot_assign_because.present? ? bold_warning('No') : "Yes"),
            cannot_assign_because.join("<br><br>")
          ]
        end
      end
    end

    private

      def to_assign
        @_to_assign = begin
          arr = []
          TO_ASSIGN_RAW.each do |(subgenus_part_of_name, species_epithets)|
            species_epithets.each do |species_epithet|
              species_name = "#{GENUS_NAME} #{species_epithet}"
              arr << [subgenus_part_of_name, species_name]
            end
          end
          arr
        end
      end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Style/ConditionalAssignment
# rubocop:enable Style/NumericPredicate
# rubocop:enable Style/SafeNavigation

__END__

title: <i>Lasius</i> subgenera to assign by script

section: pa-no-action-required
category: Catalog
tags: []

issue_description:

description: >

related_scripts:
  - LasiusSubgeneraToAssignByScript
