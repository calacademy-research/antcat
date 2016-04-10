require 'json'


#
# Import top level HOL taxa data based on names.
# Entry points are compare_with_antcat and  compare_subspecies.
#
# Not used as part of linking at present.
#
class Importers::Hol::GetHolLiterature
  include HolCommands

  def initialize
    @print_char=0
    @hol_taxa_dictionary={}
    for hol_lit in GetHolLiterature.all
      @hol_taxa_dictionary[hol_lit.tnuid]=hol_lit
    end

    puts "Done pre-loading tables"
  end


  def get_full_literature_records

    start_at = 13880
    hol_count = 0
    #for hol_hash in HolDatum.order(:name).where(taxon_id: nil, is_valid: 'Valid')
    for hol_hash in HolDatum.order(:tnuid).where(is_valid: 'Valid', taxon_id: nil)

      if hol_count > 100000
        exit
      end

      hol_count = hol_count +1

      if(hol_count < start_at)
        next
      end
      tnuid = hol_hash.tnuid
      if (@hol_taxa_dictionary.has_key?(tnuid))
        print_char '.'
        next
      end

      # puts hol_hash.name
      # puts tnuid
      # info = get_taxon_info_command hol_hash.tnuid
      lit = get_taxon_literature hol_hash.tnuid
      HolLiteraturePage.transaction do
        lit.each do |cur_lit|
          pages = cur_lit['pages']
          cur_lit['pages'] = nil
          lit_reference = GetHolLiterature.new(cur_lit)
          #lit_reference.pages = pages.to_json
          lit_reference.save!
          print_char 'S'

          pages.each do |page|
            hp = HolLiteraturePage.new page
            hp.literatures_id = lit_reference.id
            hp.save
            print_char 's'

          end
          @hol_taxa_dictionary[tnuid] = lit_reference
        end
      end
      if hol_count % 20 == 0
        print " " + hol_count.to_s + " "
        @print_char = @print_char + 2 + hol_count.to_s.length
      end
    end
  end


end
