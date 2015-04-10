class Importers::Hol::GetHolSynonyms < Importers::Hol::BaseUtils
  include HolCommands

  def initialize
    @hol_synonym_dictionary={}
    for synonym in HolSynonym.all
      @hol_synonym_dictionary[synonym.tnuid]=nil
    end

    puts "Done pre-loading tables"
  end


  def get_synonym_records

    start_at = 0
    hol_count = 0
    for hol_hash in HolDatum.order(:tnuid)

      if hol_count > 100000
        exit
      end

      hol_count = hol_count +1

      if (hol_count < start_at)
        next
      end
      tnuid = hol_hash.tnuid
      if (@hol_synonym_dictionary.has_key?(tnuid))
        print_char '.'
        next
      end

      # puts hol_hash.name
      # puts tnuid
      # info = get_taxon_info_command hol_hash.tnuid
      synonyms = get_synonyms hol_hash.tnuid
      HolSynonym.transaction do
        if synonyms.length == 0
          hol_synonym = HolSynonym.new
          hol_synonym.tnuid = hol_hash.tnuid
          hol_synonym.json = synonyms.to_json
          hol_synonym.save
          print_char 'p'
          next
        else
          synonyms.each do |cur_synonym|
            json = cur_synonym.to_json
            hol_synonym = HolSynonym.new
            hol_synonym.tnuid = hol_hash.tnuid
            hol_synonym.synonym_id = cur_synonym['tnuid']
            hol_synonym.json = json
            hol_synonym.save
            print_char 's'

          end
        end
        @hol_synonym_dictionary[tnuid] = nil
      end
    end
    if hol_count % 20 == 0
      print " " + hol_count.to_s + " "
      @print_char = @print_char + 2 + hol_count.to_s.length
    end
  end
end



