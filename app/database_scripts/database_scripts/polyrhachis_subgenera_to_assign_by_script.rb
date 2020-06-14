# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Style/ConditionalAssignment
# rubocop:disable Style/NumericPredicate
# rubocop:disable Style/SafeNavigation
module DatabaseScripts
  class PolyrhachisSubgeneraToAssignByScript < DatabaseScript
    TO_ASSIGN_RAW = {
      'Aulacomyrma' => %w[
        abdita
        annulata
        bedeloweryi
        breviata
        decora
        dohrni
        enigma
        exarata
        excellens
        gentilis
        geometrica
        gressitti
        impressa
        kokoda
        lumi
        maai
        mamba
        minima
        monticola
        orokana
        pallipes
        parva
        pelecta
        planata
        porcata
        retusa
        roberti
        roomi
        sculpta
        simulans
        snellingi
        sulcifera
        umboi
        variegata
        wamuki
        wardi
        wilsoni
      ],
      'Campomyrma' => %w[
        bispinosa
        capillata
        captiva
        cedarensis
        creusa
        curtospinosa
        equina
        eureka
        exercita
        femorata
        flavibasis
        fuscipes
        gravis
        gribodoi
        halidayi
        hashimotoi
        hauxwelli
        hespera
        hexacantha
        hirsuta
        horacei
        incerta
        inconspicua
        insularis
        io
        jacksoniana
        kohouti
        leae
        macropus
        maculata
        micans
        opacita
        ops
        palmerae
        patiens
        phryne
        polymnia
        prometheus
        pseudothrinax
        pyrrhus
        reidi
        schwiedlandi
        semipolita
        shattucki
        shixingensis
        sidnica
        smithersi
        spengeli
        sukarmani
        tambourinensis
        templi
        unicornis
        varicolor
        xiphias
        zimmerae
      ],
      'Chariomyrma' => %w[
        antennata
        appendiculata
        arcuata
        argenteosignata
        aurea
        auriformis
        aurita
        beauforti
        bedoti
        caulomma
        cingula
        coerulescens
        constricta
        contemta
        costulata
        cydista
        cyrus
        denselineata
        escherichi
        eurynota
        fulgens
        gab
        guerini
        heinlethii
        hookeri
        hostilis
        inclusa
        kaipi
        laciniata
        lata
        latinota
        leopoldi
        limbata
        loriai
        lownei
        marginata
        mentor
        modesta
        nigrescens
        nitens
        obscura
        obtusa
        opalescens
        pallescens
        punctiventris
        radicicola
        rere
        rotumana
        rowlandi
        scapulata
        schoopae
        scutulata
        senilis
        sokolova
        splendens
        subaenescens
        subcyanea
        vermiculosa
        villosa
      ],
      'Cyrtomyrma' => %w[
        abbreviata
        achterbergi
        acuminata
        albertisi
        aporema
        aruensis
        australis
        barryi
        brevicorpa
        brevinoda
        bruehli
        burmanensis
        busiris
        celebensis
        conspicua
        cornihumera
        corporaali
        cyphonota
        danum
        debilis
        decumbens
        delecta
        demangei
        dentata
        dentihumera
        dorowi
        dorsena
        emeryana
        euryala
        expressa
        fornicata
        fulakora
        gibba
        goramensis
        grandis
        hoelldobleri
        hybosa
        inducta
        inflata
        integra
        johnsoni
        jurii
        kyawthani
        laevissima
        leonidas
        lepida
        levior
        linae
        luctuosa
        mackayi
        mondoi
        monteithi
        nomo
        orbihumera
        pacifica
        pagana
        pilosa
        ralumensis
        rastellata
        robsoni
        rotoccipita
        rutila
        sedlaceki
        semiinermis
        setosa
        strumosa
        sulang
        tuberosa
        ugiensis
        undulata
        vitalisi
        wagneri
        widodoi
        yorkana
      ],
      'Hagiomyrma' => %w[
        ammon
        ammonoeides
        anderseni
        angusta
        archeri
        aurora
        bohemia
        brisbanensis
        brutella
        burwelli
        callima
        capeyorkensis
        clarki
        conciliata
        cracenta
        crawleyi
        darlingtoni
        denticulata
        diversa
        dougcooki
        electra
        elegantula
        feehani
        hoffmanni
        injinooi
        isolata
        lachesis
        lydiae
        melanura
        metella
        nourlangie
        paxilla
        penelope
        pilbara
        placida
        schenckii
        seducta
        semiaurata
        semiobscura
        stricta
        tanami
        tenebra
        thusnelda
        trapezoidea
        tubifera
        uncaria
        vernoni
        weiri
      ],
      'Hedomyrma' => %w[
        annae
        argentosa
        atropos
        barretti
        calliope
        campbelli
        circumdata
        cleopatra
        clio
        clotho
        consimilis
        cupreata
        daemeli
        erato
        euterpe
        fervens
        geminata
        hera
        hermione
        hungi
        machaon
        malaensis
        mjobergi
        ornata
        rufifemur
        santschii
        terpsichore
        tersa
        thais
        trina
        trophima
        turneri
        violaceonigra
      ],
      'Hemioptica' => %w[
        boltoni
        bugnioni
        scissa
      ],
      'Hirtomyrma' => %w[
        bamaga
        davydovi
        eremita
        greensladei
        hirta
        lama
        loweryi
        rustica
        stigmatifera
        viehmeyeri
      ],
      'Myrma' => %w[
        abrupta
        aculeata
        aenescens
        aerope
        alatisquamis
        alexisi
        alluaudi
        andrei
        andromache
        arnoldi
        asomaningi
        baca
        bakeri
        beccarii
        bosi
        brachyspina
        braxa
        brendelli
        breviorspinosa
        brevipilosa
        browni
        carbonaria
        ceramensis
        chapmani
        cognata
        compressicornis
        concava
        conops
        continua
        convexa
        cornuta
        crassispinosa
        cubaensis
        curta
        cyaniventris
        cybele
        decellei
        decemdentata
        decipiens
        diana
        dimoculata
        doudou
        dubia
        durbanensis
        edentula
        empesoi
        epinotalis
        esarata
        festina
        fisheri
        fissa
        foreli
        gagates
        gamaii
        gazelle
        gerstaeckeri
        gibbosa
        gibbula
        gobini
        hastata
        hemiopticoides
        horni
        hosei
        illaudata
        inermis
        inusitata
        isacantha
        ithona
        kebunraya
        khepra
        kohli
        labella
        laboriosa
        lanuginosa
        latharis
        latispina
        latona
        lauta
        lestoni
        limitis
        litigiosa
        longiseta
        luteipes
        manusensis
        masaokai
        medusa
        militaris
        monista
        murina
        narendrani
        neuguinensis
        nigra
        nigrita
        nigropilosa
        noesaensis
        noonananti
        numeria
        obesior
        obliqua
        ogatai
        olena
        omissa
        orsylla
        otleti
        palawanensis
        parabiotica
        paracamponota
        phidias
        philippinensis
        pirata
        planoculata
        platyomma
        procera
        proxima
        pruinosa
        pubescens
        pulleni
        punctillata
        regesa
        relucens
        revoili
        rixosa
        robusta
        rufipalpis
        rufofemorata
        salomo
        schistacea
        schlueteri
        sculpturata
        selecta
        semitestacea
        sericata
        sericeopubescens
        similis
        simpla
        sinuata
        spinicola
        spinifera
        spitteleri
        starri
        stitzi
        striata
        striatorugosa
        submarginata
        subpilosa
        sulcata
        tapini
        terminata
        transiens
        tyrannica
        vanachterbergi
        vestita
        vigilans
        villipes
        vindex
        viola
        viscosa
        volkarti
        watanasiti
        weissi
        wellmani
        wilmsi
        wolfi
        yerburyi
        zopyra
      ],
      'Myrmatopa' => %w[
        alata
        alphea
        antoniae
        bouvieri
        chaita
        charaxa
        chartifex
        constructor
        derecyna
        dolomedes
        edwardi
        elii
        excitata
        flavicornis
        follicula
        fruhstorferi
        furcula
        hilaris
        hispida
        jacobsoni
        kazuoi
        leviuscula
        lilianae
        lombokensis
        mellita
        menozzii
        neglecta
        omyrmex
        osae
        phalerata
        piliventris
        rossi
        ruficornis
        schang
        simillima
        solivaga
        solmsi
        subtridens
        sulawesiensis
        ulysses
        wallacei
        yarrabahensis
      ],
      'Myrmhopla' => %w[
        abdominalis
        aberrans
        alphena
        amana
        arachne
        arborea
        armata
        aspasia
        atrovirens
        aureovestita
        bakana
        banghaasi
        basirufa
        batesi
        bicolor
        binghamii
        bismarckensis
        bubastes
        caeciliae
        calypso
        castaneiventris
        cephalotes
        chalybea
        cleophanes
        croceiventris
        cryptoceroides
        curvispina
        daphne
        diaphanta
        diotima
        dispar
        dives
        emmae
        esuriens
        etheli
        euthiacaena
        exotica
        flavoflagellata
        fortis
        furcata
        gestroi
        glabrinotum
        glykera
        gracilior
        grisescens
        hector
        hippomanes
        hodgsoni
        hortensis
        ignota
        jerdonii
        jianghuaensis
        keratifera
        lacteipennis
        laevigata
        laminata
        longipes
        lucidula
        lugens
        magnifica
        manni
        maryatiae
        melpomene
        menelas
        mitrata
        moeschi
        moesta
        muara
        mucronata
        muelleri
        mutata
        nidificans
        nigriceps
        nigripes
        nitida
        nofra
        nudata
        ochracea
        oedacantha
        oedipus
        olybria
        orpheus
        osiris
        palaearctica
        paromala
        pellita
        peregrina
        personata
        plato
        platynota
        pressa
        punjabi
        reclinata
        regularis
        retrorsa
        rhea
        ridleyi
        romanovi
        rubigastrica
        rufipes
        rugifrons
        rupicapra
        saevissima
        salebrosa
        scabra
        schellerichae
        sexspinosa
        smithi
        sophocles
        spinigera
        spinosa
        storki
        strictifrons
        stylifera
        subfossa
        subfossoides
        sylvicola
        thailandica
        thompsoni
        tianjingshanensis
        tibialis
        tragos
        tristis
        tschu
        tubericeps
        tubifex
        venus
        vicina
        waigeuensis
        wheeleri
        wroughtonii
        xanthippe
      ],
      'Myrmothrinax' => %w[
        abnormis
        aequalis
        atossa
        cheesmanae
        cincta
        dahlii
        deceptor
        delicata
        durvillei
        eudora
        frauenfeldi
        imitator
        incognita
        javanica
        nepenthicola
        neptunus
        queenslandica
        saigonensis
        sparaxes
        textor
        thrinax
        triaena
        tricuspis
        trispinosa
        unicuspis
      ],
      'Polyrhachis' => %w[
        bellicosa
        bihamata
        craddocki
        erosispina
        lamellidens
        maliau
        mindanaensis
        montana
        taylori
        ypsilon
      ]
    }
    GENUS_NAME = 'Polyrhachis'

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

title: <i>Polyrhachis</i> subgenera to assign by script

section: pa-no-action-required
category: Catalog
tags: [new!]

issue_description:

description: >

related_scripts:
  - PolyrhachisSubgeneraToAssignByScript
