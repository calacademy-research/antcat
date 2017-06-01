require "fuzzystringmatch"

class DatabaseScripts::Scripts::PossiblyDuplicatedJournalNames
  include DatabaseScripts::DatabaseScript

  MIN_DISTANCE = 0.975

  def results
    # Build list of all journal names as strings.
    # Similar names are be converted back to journal objects in `#render`.
    @journal_names = Journal.pluck :name

    @results = []
    while @journal_names.present?
      first = @journal_names.shift # Shift name so we only match it once.
      check_similarity first
    end
    @results
  end

  def render
    as_table do
      header :journal_1, :journal_2

      rows do |first, second|
        [ journal_name_to_markdown(first), journal_name_to_markdown(second) ]
      end
    end
  end

  private
    def check_similarity first
      @journal_names.each do |second|
        next unless distance(first, second) > MIN_DISTANCE
        next if false_positive? first, second

        @results << [first, second]
      end
    end

    def distance first, second
      matcher.getDistance first, second
    end

    def matcher
      @matcher ||= FuzzyStringMatch::JaroWinkler.create :native
    end

    def false_positive? first, second
      false_positives_matches = false_positives[first]
      return unless false_positives_matches # Return if `first` is not in the list at all.
      return true if second.in? false_positives_matches
    end

    # The key is the name of a journal for which we want to exclude false
    # positives. Note that the values are arrays, but they kept on the same
    # to make the list more readable.
    def false_positives
      @false_positives ||= {
        "Acta Entomologica Chilena" => [
        "Acta Entomologica Fennica",
        "Acta Entomologica Sinica"],

        "Acta Entomologica Fennica" => [
        "Acta Entomologica Serbica",
        "Acta Entomologica Sinica"],

        "Acta Entomologica Musei Nationalis Pragae" => [
        "Acta Entomologica Musei Nationalis Pragae. Supplementum"],

        "Acta Entomologica Serbica" => [
        "Acta Entomologica Sinica",
        "Acta Entomologica Slovenica"],

        "Acta Entomologica Sinica" => [
        "Acta Entomologica Slovenica"],

        "Annales de la Société Entomologique de Belgique" => [
        "Annales de la Société Entomologique de France",
        "Annales de la Société Entomologique du Québec"],

        "Annales de la Société Entomologique de France" => [
        "Annales de la Société Entomologique du Québec"],

        "Annales des Sciences Naturelles, Botanique" => [
        "Annales des Sciences Naturelles, Zoologie"],

        "Australian Journal of Ecology" => [
        "Australian Journal of Entomology",
        "Australian Journal of Zoology"],

        "Australian Journal of Entomology" => [
        "Australian Journal of Zoology"],

        "Belgian Journal of Entomology" => [
        "Belgian Journal of Zoology"],

        "Boletim da Sociedade Portuguesa de Entomologia" => [
        "Boletim da Sociedade Portuguesa de Entomologia. Suplemento"],

        "Boletín de la Sociedad Entomológica Aragonesa" => [
        "Boletín de la Sociedad Entomológica de España"],

        "Bulletin de la Société Entomologique de Belgique" => [
        "Bulletin de la Société Entomologique de France",
        "Bulletin de la Société Entomologique de Mulhouse"],

        "Bulletin de la Société Entomologique de France" => [
        "Bulletin de la Société Entomologique de Mulhouse"],

        "Bulletin de la Société des Sciences Naturelles de Tunisie" => [
        "Bulletin de la Société des Sciences Naturelles du Maroc"],

        "Bulletin of Miscellaneous Information. Royal Botanic Gardens, Kew" => [
        "Bulletin of Miscellaneous Information. Royal Botanic Gardens, Kew. Additional Series"],

        "Conservation Biology" => [
        "Conservation Ecology"],

        "Evolutionary Biology" => [
        "Evolutionary Ecology"],

        "Israel Journal of Entomology" => [
        "Israel Journal of Zoology"],

        "Japanese Journal of Ecology" => [
        "Japanese Journal of Entomology"],

        "Journal of Applied Ecology" => [
        "Journal of Applied Entomology"],

        "Journal of the Asiatic Society of Bengal. Part II. Natural Science" => [
        "Journal of the Asiatic Society of Bengal. Part II. Physical Science"],

        "Journal of Entomology. Series A" => [
        "Journal of Entomology. Series B"],

        "Journal of Experimental Biology" => [
        "Journal of Experimental Zoology"],

        "Memoirs of the American Entomological Institute" => [
        "Memoirs of the American Entomological Society"],

        "Memoirs of the Entomological Society of Canada" => [
        "Memoirs of the Entomological Society of Washington"],

        "Mémoires de la Société Entomologique de Belgique" => [
        "Mémoires de la Société Entomologique du Québec"],

        "Proceedings of the Entomological Society of London" => [
        "Proceedings of the Entomological Society of Manitoba",
        "Proceedings of the Entomological Society of Philadelphia",
        "Proceedings of the Entomological Society of Washington"],

        "Proceedings of the Entomological Society of Manitoba" => [
        "Proceedings of the Entomological Society of Philadelphia",
        "Proceedings of the Entomological Society of Washington"],

        "Proceedings of the Entomological Society of Philadelphia" => [
        "Proceedings of the Entomological Society of Washington"],

        "Proceedings of the Royal Entomological Society of London. Series A" => [
        "Proceedings of the Royal Entomological Society of London. Series B"],

        "Proceedings of the Royal Society of Queensland" => [
        "Proceedings of the Royal Society of Victoria"],

        "Records of the Western Australian Museum" => [
        "Records of the Western Australian Museum Supplement"],

        "Revista Brasileira de Biologia" => [
        "Revista Brasileira de Zoologia"],

        "Revista Brasileira de Entomologia" => [
        "Revista Brasileira de Zoologia"],

        "Studii si Cercetari de Biologie. Seria Biologie Animala" => [
        "Studii si Cercetari de Biologie. Seria Zoologie"],

        "Transactions of the Entomological Society of London" => [
        "Transactions of the Entomological Society of New South Wales"],

        "Transactions of the American Entomological Society" => [
        "Transactions of the American Entomological Society, Suppl. Vol."],

        "Zeitschrift für Angewandte Entomologie" => [
        "Zeitschrift für Angewandte Zoologie"],

        "Zoologische Jahrbücher. Abteilung für Systematik, Geographie und Biologie der Tiere" => [
        "Zoologische Jahrbücher. Abteilung für Systematik, Ökologie und Geographie der Tiere"],
      }
    end

    def journal_name_to_markdown journal_name
      journal = Journal.find_by name: journal_name
      "%journal#{journal.id}"
    end
end

__END__
description: >
  Additional false positives (see the script's source)
  can be added to the exclusion list on request.

tags: [slow]
topic_areas: [references]
