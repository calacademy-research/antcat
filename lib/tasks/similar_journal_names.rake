require "fuzzystringmatch"

namespace :antcat do
  namespace :db do

    desc "Find similar journal names; MIN_DISTANCE=0.975; FORMAT=[hacker|markdown]"
    task similar_journal_names: :environment do
      MIN_DISTANCE = (ENV["MIN_DISTANCE"] || 0.975).to_f
      FORMAT = ENV["FORMAT"] || "hacker"

      FALSE_POSITIVES = {
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

      @jarow = FuzzyStringMatch::JaroWinkler.create :native
      @journal_names = Journal.pluck :name
      @similar_names_count = 0

      def check_similarity first
        @journal_names.each do |second|
          distance = @jarow.getDistance first, second
          if distance > MIN_DISTANCE
            next if false_positive? first, second
            @similar_names_count += 1
            print_in_terminal first, second, distance
          end
        end
      end

      def false_positive? first, second
        match = FALSE_POSITIVES[first]
        return unless match
        return true if second.in? match
      end

      def print_in_terminal first, second, distance
        case FORMAT
        # hacker style; many colors, looks like you're hacking a bank
        when "hacker"
          puts "---------- similarity: #{distance} ----------"
          puts "#{first}".red
          puts "#{second}".green
          puts "#{journal_url first}"
          puts "#{journal_url second}"
        # for pasting into open tasks so that editors can cleanup the duplicates
        when "markdown"
          puts "___" # horizontal rule
          puts "#{journal_markdown first}"
          puts "#{journal_markdown second}\n"
        end
      end

      def journal_url journal_name
        journal = Journal.find_by(name: journal_name)
        "http://antcat.org/journals/#{journal.id}"
      end

      # Looks like this: Zootaxa (%j123)
      def journal_markdown journal_name
        journal = Journal.find_by(name: journal_name)
        "#{journal_name} (%j#{journal.id})"
      end

      # Header
      time = Time.zone.now
      puts "Journal names similarity report #{time} (for finding duplicates)"
      puts "Generated by script at #{time}"
      puts "Minimum distance (0-1): #{MIN_DISTANCE}"
      puts "False positives master list: #{FALSE_POSITIVES.size} items"

      # Body list
      while @journal_names.present?
        first = @journal_names.shift
        check_similarity first
      end

      # Footer
      puts "__"
      puts "Similar names found: #{@similar_names_count}"
    end

  end
end
