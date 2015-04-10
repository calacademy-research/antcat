require 'fuzzystringmatch'


class Importers::Hol::BaseUtils
# does this: details_hash['orig_desc']['author_extended'][0]['initials']
# from this: extract details_hash, ["orig_desc", "author_extended", 0, "initials"]
# and does puts on exceptions
  def initialize
    @candidate_id = nil
    @candidate_antcat_string = nil
    @candidate_distance = 0
    @jarow = FuzzyStringMatch::JaroWinkler.create(:pure)

  end

  def extract hash, hash_key_array
    if (hash.nil?)
      return nil
    end
    hash_key = hash_key_array.shift
    ret_val = hash[hash_key]
    if ret_val.nil?
      #print_char("#")
      #puts "Unable to extract " + hash_key.to_s
    end
    if (hash_key_array.length == 0)
      return ret_val
    else
      return extract ret_val, hash_key_array
    end
  end


  @@print_char = 0

  def print_char char
    if @@print_char>=80
      @@print_char=0
      puts char
    else
      print char
      @@print_char = @@print_char + 1
    end
  end

  def print_string p_string
    p_string = " " + p_string.to_s + " "
    if @@print_char>=80
      @@print_char=0
      puts p_string
    else
      print p_string
    end
    @@print_char = @@print_char + p_string.length
  end


  def clear_candidate
    @candidate_id = nil
    @candidate_antcat_string = nil
    @candidate_distance = 0
  end


  def check_and_swap_reference
    if @candidate_id.nil?
      @candidate_id = @cur_id
      @candidate_antcat_string = @cur_string
      @candidate_distance = @jarow.getDistance(@candidate_antcat_string, @hol_string)
      Rails.logger.debug " first example:" + @cur_string+ " " + @candidate_distance.to_s
    else
      if @cur_id == @candidate_id
        # Rails.logger.debug "these are the same, skipping"
        return
      end

      swap_if_better @jarow.getDistance(@cur_string, @hol_string)
    end
  end

  def swap_if_better new_distance
    if new_distance > @candidate_distance
      @candidate_id = @cur_id
      @candidate_antcat_string = @cur_string
      @candidate_distance = new_distance
      Rails.logger.debug " I like this better: " + @candidate_antcat_string+ " " + new_distance.to_s
    else
      Rails.logger.debug " Kept the old one: " + @cur_string+ " " + new_distance.to_s
    end
  end


  def filter_result string_map
    if @candidate_distance > 0.75
      Rails.logger.debug ("The winner is: " + @candidate_antcat_string)
      string_map[@hol_string] = @candidate_antcat_string
      return @candidate_id
    else
      if @candidate_id.nil?
        Rails.logger.warn ("No mapping found for: " +@hol_string)
      else
        Rails.logger.warn (@hol_string + " just isn't close enough to "+@candidate_antcat_string+". Discarding.")
      end
      string_map[@hol_string] = nil

      return nil
    end
  end

  def reference_search hol_string
    @hol_string = hol_string

    references = string_search hol_string
    clear_candidate
    if (references.length == 0)
      Rails.logger.debug "references: No references found."
      return nil
    end
    references
  end


  def string_search search_string
    # This is not too useful; it only returns on perfect matches.
    # params={filter: :no_missing_references,
    #         is_author_string: true,
    #         author_names: search_string}
    params={filter: :no_missing_references,
            fulltext: search_string}
    Reference.perform_search params

  end

  def get_page_from_string page_string
    start_page = nil
    end_page = nil
    if match = get_page_from_string.match(/([0-9]+)-([0-9]+)/)
      start_page = match[1].to_i
      end_page = match[2].to_i
    elsif   match = get_page_from_string.match(/(([ivcx]+) \+ )*([0-9]+)/)
      start_page = match[1].to_i
      end_page = match[2].to_i
    end
    return {start_page: start_page, end_page: end_page}
  end

  # is start_page and end_page contained in the page hash?
  def page_in_range page_hash, internal_start_page,internal_end_page
    start_page = page_hash[:start_page]
    end_page = page_hash[:end_page]
    # the antcat page ranges, ok.
    unless internal_start_page.nil? || start_page.nil?
      if start_page > internal_start_page
        puts ("Page start range mismatch")
        return false
      end
    end
    unless internal_end_page.nil? || end_page.nil?
      if end_page < internal_end_page
        puts ("Page end range mismatch")
        return false
      end
    end
    true
  end

end
