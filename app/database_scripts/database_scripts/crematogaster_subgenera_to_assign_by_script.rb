# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Style/ConditionalAssignment
# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/SafeNavigation
module DatabaseScripts
  class CrematogasterSubgeneraToAssignByScript < DatabaseScript
    TO_ASSIGN_RAW = {
      'Orthocrema' => %w[
        abstinens
        aculeata
        acuta
        aitkenii
        amapaensis
        ampla
        arata
        arcuata
        atra
        baduvi
        binghamii
        bingo
        biroi
        boera
        bogojawlenskii
        boliviana
        brasiliensis
        brevidentata
        brevimandibularis
        brevis
        bruchi
        bryophilia
        carinata
        chodati
        cisplatinalis
        corticicola
        corvina
        crassicornis
        crinosa
        cristata
        crucis
        cubaensis
        curvispinosa
        delitescens
        dispar
        distans
        dolens
        dorsidens
        egregior
        emeryi
        erecta
        euterpe
        evallans
        flavomicrops
        flavosensitiva
        foliocrypta
        formosa
        fritzi
        gavapiga
        goeldii
        gratiosa
        heathi
        huberi
        iheringi
        indefensa
        insularis
        iridipennis
        jardinero
        javanica
        jeanneli
        laevis
        levior
        limata
        littoralis
        longipilosa
        longispina
        lutzi
        madecassa
        magnifica
        mancocapaci
        masukoi
        mesonotalis
        minutissima
        moelleri
        montana
        monteverdensis
        montezumia
        mpanjono
        muralti
        myops
        natalensis
        nigropilosa
        nitidiceps
        obscurata
        osakensis
        overbecki
        oxygynoides
        pallida
        pallipes
        paradoxa
        parallela
        pauciseta
        pauli
        peristerica
        peruviana
        polymnia
        pulchella
        pygmaea
        quadriformis
        quadrispinosa
        queenslandica
        ralumensis
        raptor
        rasoherinae
        razana
        rectinota
        resulcata
        reticulata
        rochai
        rudis
        rufotestacea
        russata
        russoi
        scapamaris
        scelerata
        schimmeri
        scita
        sericea
        snellingi
        sordidula
        sotobosque
        steinheili
        stigmatica
        stollii
        subtonsa
        suehiro
        sumichrasti
        telolafy
        tenuicula
        thalia
        torosa
        transvaalensis
        udo
        unciata
        uruguayensis
        ustiventris
        vicina
        victima
        volamena
        wardi
        wheeleri
        xerophila
      ],
      'Crematogaster' => %w[
        abdominalis
        aberrans
        abrupta
        acaciae
        adrepens
        aegyptiaca
        affabilis
        afghanica
        africana
        agnetis
        agniae
        algirica
        alluaudi
        aloysiisabaudiae
        alulai
        amabilis
        ambigua
        amita
        ampullaris
        ancipitula
        angulosa
        angusticeps
        antaris
        anthracina
        apicalis
        arnoldi
        aroensis
        arthurimuelleri
        ashmeadi
        atkinsoni
        auberti
        augusti
        aurita
        australis
        bakeri
        batesi
        bequaerti
        betapicalis
        bicolor
        biformis
        bison
        borneensis
        bouvardi
        breviventris
        browni
        brunnea
        brunneipennis
        brunnescens
        buchneri
        buddhae
        butteli
        californica
        capensis
        captiosa
        castanea
        censor
        cephalotes
        cerasi
        chiarinii
        chlorotica
        chopardi
        chungi
        cicatriculosa
        clariventris
        clydia
        coarctata
        coelestis
        colei
        concava
        constructor
        coriaria
        cornigera
        cornuta
        corporaali
        cuvierae
        cylindriceps
        dahlii
        daisyi
        dalyi
        decamera
        degeeri
        delagoensis
        dentinodis
        depilis
        depressa
        desecta
        desperans
        difformis
        diffusa
        dohrni
        donisthorpei
        dubia
        ebenina
        edentula
        egidyi
        elegans
        elysii
        emeryana
        enneamera
        ensifera
        eurydice
        excisa
        ferrarii
        flava
        flavicornis
        flavitarsis
        flaviventris
        foraminiceps
        foxi
        fraxatrix
        frivola
        fruhstorferi
        fuentei
        fusca
        gabonensis
        gallicola
        gambiensis
        gerstaeckeri
        gibba
        gordani
        grevei
        gutenbergi
        hemiceros
        hespera
        hezaradjatica
        himalayana
        hogsoni
        homeri
        hottentota
        hova
        ilgii
        impressa
        impressiceps
        inconspicua
        incorrecta
        inermis
        inflata
        innocens
        ionia
        irritabilis
        isolata
        jacobsoni
        jehovae
        jullieni
        juventa
        kachelibae
        karawaiewi
        kasaiensis
        kelleri
        kirbii
        kneri
        kohlii
        kojimai
        kutteri
        laestrygon
        laeviceps
        laevissima
        laeviuscula
        lamottei
        lango
        larrae
        latuka
        laurenti
        ledouxi
        libengensis
        liengmei
        lineolata
        lobata
        longicephala
        longiceps
        longiclava
        lorteti
        lotti
        lucayana
        luctans
        macaoensis
        macracantha
        madagascariensis
        magitae
        mahery
        major
        malala
        manni
        margaritae
        marioni
        marthae
        matsurumai
        meijerei
        melanogaster
        menilekii
        microspina
        mimosae
        misella
        mjobergi
        modiglianii
        montenigrina
        monticola
        moqorensis
        mormonum
        motazzi
        mucronata
        mutans
        navajoa
        nawai
        nesiotis
        neuvillei
        nigeriensis
        nigrans
        nigriceps
        nigronitens
        nocturna
        nosibeensis
        oasium
        obnigra
        obscura
        ochracea
        ochraceiventris
        onusta
        opaca
        opaciceps
        opuntiae
        orobia
        oscaris
        painei
        paolii
        patei
        pellens
        perelegans
        peringueyi
        petiolidens
        phoenica
        phoenix
        physothorax
        pia
        pilosa
        pinicola
        polita
        politula
        popohana
        pradipi
        pseudinermis
        pythia
        ranavalonae
        ransonneti
        recurva
        retifera
        rifelna
        rivai
        rogenhoferi
        rogeri
        ronganensis
        rossi
        rothneyi
        rufa
        rufigena
        rugosa
        rugosior
        ruspolii
        rustica
        sabatra
        sagei
        sanguinea
        santschii
        saussurei
        schencki
        schmidti
        schultzei
        scutellaris
        semperi
        senegalensis
        sewardi
        sewellii
        similis
        simoni
        sisa
        skounensis
        solenopsides
        solers
        sorokini
        soror
        spengeli
        stadelmanni
        stenocephala
        stigmata
        striatula
        subcircularis
        subdentata
        subnuda
        tanakai
        tarsata
        teranishii
        tetracantha
        theta
        togoensis
        transiens
        trautweini
        tranvancorensis
        treubi
        tumidula
        urvijae
        vacca
        vagula
        vandeli
        vandermeermohri
        vermiculata
        vidua
        vitalisi
        vulcania
        walshi
        warburgi
        wasmanni
        weberi
        wellmani
        werneri
        whitei
        wilwerthi
        wroughtonii
        yamanei
        yappi
        zavattarii
        zoceensis
        zonacaciae
      ]
    }
    GENUS_NAME = 'Crematogaster'

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

title: <i>Crematogaster</i> subgenera to assign by script

section: pa-no-action-required
category: Catalog
tags: [new!]

issue_description:

description: >

related_scripts:
  - CrematogasterSubgeneraToAssignByScript
