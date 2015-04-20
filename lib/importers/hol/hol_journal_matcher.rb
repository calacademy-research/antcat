require 'fuzzystringmatch'


class Importers::Hol::HolJournalMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
    # Map from hol name to antcat name

    #

    @journal_name_string_map ={"Revista de Entomologia (Rio de Janeiro)" =>
                                   "Revista de Entomología, Rio de Janeiro",
                               "Bollettino del Laboratorio di Zoologia Generale e Agraria della R. Scuola Superiore d'Agricultura" =>
                                   "Bollettino del Laboratorio di Zoologia Generale e Agraria della Reale Scuola Superiore d'Agricoltura",
                               "Annales de la Société Entomologique de Belgique, Comptes-rendus des Seances" =>
                                   "Annales de la Société Entomologique de Belgique",
                               "Sitzungsberichte der Koenigliche Akademie der Wissenschaften, Mathematisch-Naturwissenschaftliche Classe" =>
                                   "Sitzungsberichte der Kaiserlichen Akademie der Wissenschaften in Wien. Mathematisch-Naturwissenschaftliche Classe. Abteilung I"}



    # Misses, sorted by frequency:

    #
    # "Histoire Physique, Naturelle et Politique de Madagascar",281
    # "Mitteilungen aus dem Zoologische Museum in Berlin",265
    # "Rendiconto delle Sessioni della R. Accademia delle Scienze dell'Istituto di Bologna",260
    # "Studia Entomologica (N.S.)",221
    # "Journal des Museum Goddefroy",197
    # "Sitzungsberichte der Bayerischen Akademie der Wissenschaften zu Muenchen, Mathematisch-Physikalische Klasse",177
    # "Species des Hyménoptères d'Europe et d'Algérie",174
    # "Beiträge zur Naturkunde Preussens Königlichen Physikalisch-Oekonomischen Gesellschaft zu Königsberg",155
    # "Zoologische und Anthropologische Ergebnisse einer Forschungsreise im Westlichen und Zentralen Südafrika",155
    # "Trudy Ukrains'ka Akademiya Nauk Fizichno-Matematichnoho Viddilu",136
    # "Bollettino dei Musei di Zoologia ed Anatomia Comparata della R. Universita di Torino",131
    # "Göteborgs Kungliga Vetenskaps- och Vitterhetssamhälles Handlingar",126
    # "Voyage de Ch. Alluaud et R. Jeannel en Afrique Orientale (1911-1912). Résultats scientifiques. Hyménoptères",123
    # "Revista de Entomología, São Paulo",120
    # "Encyclopédie Methodique",117
    # "Jahrbücher des Vereins für Naturkunde im Herzogthum Nassau",106
    # "Yezhegodnik Zoologicheskogo Muzeya Imperatorskoi Akademii Nauk",105
    # "Russkoye Entomologicheskoye Obozreniye",103
    # "Arcana Entomologica",94
    # "Eos",88
    # "Entomologists Record and Journal of Variation",87
    # "Annuario della Societa dei Naturalisti Modena",84
    # "Entomologists Monthly Magazine",78
    # "Trudy Vseukrains'ka Akademiya Nauk Fizichno-Matematichnoho Viddilu",72
    # "Bolletino della Societa Adriatica di Scienze Naturali",64
    # "Contributions in Science, Natural History Museum of Los Angeles County",56
    # "Abhandlungen und Berichte des Koeniglichen Zoologischen und Anthropologisch-Ethnographischen Museums zu Dresden",54
    # "Entomologicheskoye Obozreniye",46
    # "Abhandlungen herausgegeben von der Senckenbergischen Naturforschenden Gesellschaft",43
    # "Comunicaciones del Museo Nacional de Historia Natural &quot;Bernardino Rivadavia&quot;",41
    # "Transactions and Proceedings of the Royal Society of South Australia",41
    # "Boll. R. Lab. Entomol. Agr. Portici",40
    # "Annales de la Société Entomologique de France (n.s.)",32
    # "Wissenschaftliche Ergebnisse der Schwedischen Zoologischen Expedition nach dem Kilimandjaro, dem Meru und den Umgebenden Massaisteppen Deutsch-Ostafrikas 1905-1906",32
    # "Bulletin de l'Academie Polonaise des Sciences. Cl. 2",29
    # "Société Entomologique de France, Livre du Centenaire",29
    # "Insects of Samoa and Other Samoan Terrestrial Arthropods",26
    # "Abhandlungen zur Geologischen Specialkarte von Elsass-Lothringen",25
    # "Societas Scientiarum Fennica Commentationes Biologicae",24
    # "Trudy Instytutu Zoolohii ta Biolohii Ukrains'ka Akademiya Nauk",23
    # "Faune Hyménoptèrologique de la Province de Québec",20
    # "Bulletin du Musee Royal d'Histoire Naturelle Belge",19
    # "Boletim Biologico, Rio de Janeiro",18
    # "Zapiski Vladivostokskogo Otdela Gosudarstvennogo Russkogo Geograficheskogo Obshchestva",18
    # "Mittheilungen des Münchener Entomologischen Vereins",17
    # "Papeis Avulsos do Departamento de Zoologia",17
    # "Real Sociedad Española de Historia Natural, Memorias, Tomo del Cincuentenario",17
    # "Search: Agriculture; Cornell University Agricultural Experiment Station",17
    # "Atti della Societa Italiana di Scienze Naturali",15
    # "Trudy Sredne-Aziatskogo Gosudarstvennogo Universiteta",15
    # "Annales du Musée Royal du Congo Belge, Nouvelle Série in-4°, Sciences Zoologiques",14
    # "Archivos da Escola Superior da Agricultura e Medecina Veterinaria",14
    # "Pacific Entomological Survey Publication",14
    # "Videnskabelige Meddelelser Naturhistorisk Forening i København",13
    # "Bollettino dell'Istituto di Entomologia della Universita di Bologna",12
    # "Malaysian Journal of Sciene",12
    # "Memoirs and Proceedings of the Manchester Literary and Philosphical Society",12
    # "Izvestiya Instituta Issledovateli Sibiri (Tomsk)",11
    # "Zapateri, Revista Aragonensa de Entomologia",11
    # "Annales de la Société Entomologique de France, Bulletins Trimestriels",10
    # "Berichte des Naturwissenschaftlich-Medizinischen Veriens in Innsbruck",10
    # "Entomologicke Prirucky",10
    # "Occasional Papers Bernice P. Bishop Museum",10
    # "Coleción de Estudios Altoaragoneses",9
    # "Faunistische Abhandlungen aus dem Staatlichen Museum für Tierkunde in Dresden",8
    # "Izvestiya Imperatorskago Tomskogo Universiteta",7
    # "An die Zuercherische Jugend auf das Jahr 1852 von der Naturforschenden Gesellschaft",6
    # "Casopis Moravskeho Musea",6
    # "Entomologicheskie Issledovanie v Kirgizii",6
    # "Neujahrsblatt Herausgegeben von der Naturforschenden Gesellschaft In Zürich",6
    # "Sitzungsberichte der Gesellschaft für Morphologie und Physiologie in München",6
    # "Zbirnyk Prats' Zoolohichnoho Muzeyu Instytut Zoolohii ta Biolohii an URSR",6
    # "Zoologische Beitraege (N.F.)",6
    # "Abhandlungen der Senckenbergischen Naturforschenden Gesellschaft Frankfurt am Main",5
    # "Archives Trimestrielles de l'Institut Grand-Ducal, Section des Sciences",5
    # "Columbia University Biological Series",5
    # "Fragmenta Entomologica, Roma",5
    # "Meddelelser fra det Zoologiske Museum Oslo",5
    # "Natuurwetenschappelijke Studiekring voor Suriname en Curacao",5
    # "Nouvelle Revue d'Entomologie (n.s.)",5
    # "Proceedings of the 2nd International Conference of the Entomological Society of Egypt",5
    # "Registro Trimestre o Coleccion de Memorias de Historia, Literatura, Ciencias y Artes",5
    # "The Natural History of Juan Fernandez and Easter Island",5
    # "Trudy Zoologicheskogo Instituta Akademii Nauk SSSR",5
    # "Übersicht der Arbeiten und Veränderungen der Schlesischen Gesellschaft fuer Vaterländische Kultur im Jahre 1838",5
    # "Annuario del Museo Zoologico della R. Universita di Napoli",4
    # "Archiv für Hydrobiologie Supplement",4
    # "Atti dell'Accademia delle Scienze Fisiche e Matematiche. Napoli",4
    # "Atti della Accademia Gioenia di Scienze Naturali in Catania",4
    # "Biodiversity of South America, I. Memoirs on Biodiversity",4
    # "Bulletins de l'Academie Royale des Sciences et Belles-Lettres de Bruxelles",4
    # "Le Naturaliste",4
    # "Memorias do Instituto Oswaldo Cruz",4
    # "Naturaliste (Revue Illustrée des Sciences Naturelles)",4
    # "Poeyana",4
    # "Proceedings of the Royal Entomological Society of London",4
    # "Sessio Conjuncta d'Entomologia ICHN-SCL",4
    # "Sitzungsberichte der Oesterreichische Akademie der Wissenschaften, Mathematisch-Naturwissenschaftliche Klasse",4
    # "Sprawozdanie Komisji Fizjograficznej",4
    # "Transactions of the Linnean Society of London, Zoology",4
    # "Yezhegodnik Zoologicheskogo Muzeya Akademii Nauk SSSR",4
    # "Zoologische Jahrbücher, Abteilung für Systematik, Ökologie und Geographie der Tiere",4
    # "Annales des Sciences Naturelles (Zoologie)",3
    # "Annales des Sciences Naturelles Botanique",3
    # "Archivos do Instituto de Biologia Vegetal",3
    # "Archivos do Museu Nacional",3
    # "Archivum Zoologicum",3
    # "Biological Bulletin",3
    # "Boletim do Museu Nacional",3
    # "Buletinul Societatii de Stiinte din Bucuresti-Romania",3
    # "Bulletin de la Société Entomologique d'Egypte",3
    # "Bulletin des Sciences par la Société Philomathique",3
    # "Bulletin et Annales de la Société Entomologique de Belge",3
    # "Bulletin et Annales de la Société Royale d'Entomologie de Belgique",3
    # "Bulletin Vaudoise des Sciences Naturelles",3
    # "Carnegie Institution of Washington, Publication",3
    # "Casopis Moravskeho Zemskeho Musea",3
    # "Denkschriften der Akademie der Wissenschaften in Wien (Mathematisch-Naturwissenschaftliche Klasse)",3
    # "Entomologische Mitteilungen",3
    # "Folia Universitaria Cochabamba",3
    # "Formosan Entomology",3
    # "Izvestiya Imperatorskago Obshchestva Lyubitelei Estestvoznaniya, Antropologii i Etnografii",3
    # "Journal of Beijing Forestry University",3
    # "Journal of the Asiatic Society of Bengal. Part 2. Natural Science",3
    # "Journal of the Proceedings of the Linnean Society of London, Zoology",3
    # "Mémoires du Musée Royal d'Histoire Naturelles de Belgique",3
    # "Memorias y Revista de la Sociedad Cientifica &quot;Antonio Alzate&quot;",3
    # "Memorie della R. Accademia delle Scienze dell'Istituto di Bologna",3
    # "Occasional Papers: National Museum of Southern Rhodesia",3
    # "PlosOne",3
    # "Proceedings of the American Academy of Arts & Sciences",3
    # "Publications de l'Université Libanaise, Section des Sciences Naturelles",3
    # "Report of Progress, Geological Survey of Canada",3
    # "Revue de Zoologie Africaine",3
    # "Societas Entomologica",3
    # "The Canadian Entomologist",3
    # "The Entomologist",3
    # "Trudy Paleontologicheskogo Instituta",3
    # "Trudy Paleozoologicheskogo Instituta, Akademiya Nauk SSSR",3
    # "Verhandlungen der Koninklijke Akademie van Wetenschappen te Amsterdam",3
    # "Verhandlungen des Zoologisch-Botanischen Vereins in Wien",3
    # "Victorian Naturalist",3
    # "Zoologica",3
    # "Zoological Journal",3
    # "Zoologische Jahrbücher, Abteilung für Systematik, Geographie und Biologie der Tiere",3
    # "Zoologische Jahrbücher, Supplement",3
    # "Actas de la Sociedad Española de Historia Natural",2
    # "Anales del Museo Nacional de Buenos Aires",2
    # "Annales de la Faculte des Sciences du Cameroun",2
    # "Annales des Epiphytes",2
    # "Annales Zoologici",2
    # "Annali del Museo Civico di Storia Naturale Giacomo Doria (Genova)",2
    # "Annali dell'Accademia degli Aspiranti Naturalisti",2
    # "Annals of Zoology",2
    # "Annotationes Zoologicae Japonensis",2
    # "Arquivos de Zoologia",2
    # "Arthropod Fauna of the United Arab Emirates",2
    # "Atti del Museo Civico di Storia Naturale Trieste",2
    # "Atti della Società Italiana die Scienze Naturali e del Museo Civico die Storia Naturale. Milano",2
    # "Bulletin de la Société d'Histoire Naturelle de Metz",2
    # "Bulletin of the British Museum (Natural History) Entomology",2
    # "Cornell University Agricultural Experiment Station Memoir",2
    # "Entomological Magazine, Kyoto",2
    # "Entomological World",2
    # "Entomologische Abhandlungen des Staatlichen Museums für Tierkunde Dresden",2
    # "Esakia, Special Issue",2
    # "Indian Forest Records",2
    # "Izvestiya Tomskogo Universiteta",2
    # "Jahrbuch der Kaiserlich Königlichen Geologischen Reichsanstalt.",2
    # "Journal of the Entomological Society of South Africa",2
    # "Journal of the Faculty of Science, Hokkaido University",2
    # "Le Naturaliste Canadien",2
    # "Magazin für Insektenkunde",2
    # "Memoirs of the National Science Museum",2
    # "Memorias de la Sociedad Cubana de Historia Natural",2
    # "Miscellania Zoologica",2
    # "Mitteilungen der Arbeitsgemeinschaft für Naturwissenschaften",2
    # "Natura Montenegrina, Podgorica",2
    # "Natural History Museum of Los Angeles County Science Bulletin",2
    # "Naturalista Siciliano",2
    # "Nunquam Otiosus",2
    # "Perspectives on Biosystematics and Biodiversity",2
    # "Proceedings of the National Academy of Science",2
    # "Proceedings of the Rhodesia Scientific Association",2
    # "Rendiconti del Seminario della Facolta di Scienze della Universita di Cagliari",2
    # "Revista de la Asociación Paleontológica Argentina",2
    # "Science & Culture",2
    # "Sitzungsberichte der Akademie der Wissenschaften, Mathematisch-Naturwissenschaftliche Klasse, Wien",2
    # "Southwestern Naturalist",2
    # "Sovestskaya Geologiya",2
    # "Stuttgarter Beiträge zur Naturkunde",2
    # "University of Colorado Studies, Series in Biology",2
    # "Verhandlungen des Naturhistorischen Vereines de Preussischen Rheinlande und Westfalens",2
    # "Vie et Milieu",2
    # "Zapiski po Obshchei Geografii Imperatorskago Russkago Geograficheskago Obshchestva",2
    # "Zeitschrift für Entomologie",2
    # "Annales de l'Universite de l'Abidjan (Sciences)",1
    # "Annales Universitatis Mariae Curie-Sklodowska",1
    # "Archives Institut Grand-Ducal de Luxembourg (n.s.)",1
    # "Arquivos da Universidade Federal Rural de Rio de Janeiro",1
    # "Arquivos do Museu Nacional",1
    # "Arthropod Systematics & Phylogeny",1
    # "Brigham Young University Science Bulletin",1
    # "Bulletin de l'Institut Français d'Afrique Noire",1
    # "Bulletin de la Société Fouad 1er d'Entomologie",1
    # "Bulletin of the Natural History Museum (Entomology)",1
    # "Calodema Supplementary Paper",1
    # "Casopis Narodniho Musea",1
    # "Comptes Rendus Hebdomadaire des Séances de l'Académie des Sciences",1
    # "Current Science",1
    # "Eclogae geologicae Helveticae",1
    # "Entomofauna, Zeitschrift für Entomologie",1
    # "EPHE, Biologie et Evolution des Insectes",1
    # "Etudes Entomologiques",1
    # "Fauna Mundi",1
    # "Fragmenta Faunistica",1
    # "Genus",1
    # "Geobios new Reports",1
    # "Insect Systematics & Evolution",1
    # "Insects of Xizang",1
    # "Jahrbücher des Nassauischen Vereins für Naturkunde",1
    # "Journal of Entomological Research",1
    # "Journal of Hubei University (Natural Science Edition)",1
    # "Journal of Proceedings of the Entomological Society of London",1
    # "Journal of Shaanxi Normal University (Natural Science Edition)",1
    # "Journal of the Academy of Natural Sciences of Philadelphia",1
    # "Mem. Acad. Sci. Inst. Imp. France",1
    # "Museo Regionale di Scienze Naturali, Monografie",1
    # "Nature and Human Activities",1
    # "Öfversigt af Kongliga Vetenskaps-Akadamiens Förhandlingar",1
    # "Pacific Insects Monographs",1
    # "Philippine Entomologist",1
    # "Proceedings of the Royal Society B",1
    # "Quid",1
    # "Revista de la Asociación Geológica Argentina",1
    # "Science Reports of the Faculty of Education, Gifu University",1
    # "State Fauna Series 4: Fauna of Meghalaya",1
    # "Studies on Neotropical Fauna and Environment",1
    # "The Raffles Bulletin of Zoology",1
    # "Trudy Biologicheskogo Nauchno-Issledovatel'skogo Instituta",1
    # "Trudy Tomskogo Universiteta",1
    # "University of Iowa Studies in Natural History",1
    # "Vesci Nacyjanal'naj Akademii Navuk Belarusi. Seryja bijalagicnyh Navuk",1
    # "Zoological Science",1
    # "Zoologische Mededelingen",1

  end

  def get_original_hol_journal value
    @journal_name_string_map.key(value)
  end

  def get_antcat_journal hol_journal_name
    Rails.logger.level = Logger::INFO


    if hol_journal_name.nil?
      return nil
    end
    journal = Journal.find_by_name hol_journal_name
    if journal.nil? && @journal_name_string_map.has_key?(hol_journal_name)
      mapped_name = @journal_name_string_map[hol_journal_name]
      if mapped_name.nil?
        return nil
      end

      Rails.logger.debug "Hey, we know this one. Here it is: " + mapped_name
      return Journal.find_by_name(mapped_name)
    end
    if journal.nil?
      return journal_search_matcher hol_journal_name
    end
    journal

  end

  def journal_search_matcher hol_string
    Rails.logger.level = Logger::INFO

    references = reference_search hol_string
    if references.nil?
      return nil
    end

    references.each do |reference|
      if reference.journal.nil?
        next
      end
      @cur_string = reference.journal.name
      @cur_id = reference.journal.id
      Rails.logger.debug "found a:" + @cur_string.to_s + " "
      check_and_swap_reference
    end
    return filter_result @journal_name_string_map
  end


end
