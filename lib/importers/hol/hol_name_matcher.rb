class Importers::Hol::HolNameMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
    @name_string_map ={}
    @match_previous_genus_regexp_pattern = /^([a-zA-Z]+) (\(([a-zA-Z]+)\)) ([a-z .A-Z]+)/
  end

  def get_original_hol_name value
    @name_string_map.key(value)
  end

  def get_previous_genus_from_string string
    if  match = string.match(@match_previous_genus_regexp_pattern)
      return match[3]
    end
    nil
  end

  def get_previous_genus_from_hash hol_hash
    hol_name = hol_hash['name']
    if hol_name.nil?
      return nil
    end
    get_previous_genus_from_string hol_name
  end

  def get_name_without_previous_genus name_string
    if match = name_string.match(@match_previous_genus_regexp_pattern)
       match[1] + " " + match[4]
    else
       name_string
    end
  end

  def get_current_genus_from_string name_string
    if  match = name_string.match(@match_previous_genus_regexp_pattern)
      return match[1]
    end
    nil
  end

  def get_full_previous_name_from_string name_string
    return get_previous_genus_from_string(name_string) + " "+ get_suffix_from_string(name_string)
  end

  def get_full_current_name_from_string name_string
    return get_current_genus_from_string(name_string)+ " "+ get_suffix_from_string(name_string)

  end

  def get_suffix_from_string name_string
    if  match = name_string.match(@match_previous_genus_regexp_pattern)
      return match[4]
    end
    nil
  end

  def get_current_genus_from_hash hol_hash
    hol_name = hol_hash['name']
    if hol_name.nil?
      return nil
    end
    get_current_genus_from_string hol_name
  end

  def get_antcat_name_from_string hol_name
    if hol_name.nil?
      return nil
    end

    name = Name.find_by_name hol_name
    if name.nil? && @name_string_map.has_key?(hol_name)
      mapped_name = @name_string_map[hol_name]
      if mapped_name.nil?
        return nil
      end

      Rails.logger.debug "Hey, we know this one. Here it is: " + mapped_name
      return Name.find_by_name(mapped_name).id
    end
    # if name is still nil here, this is were we'd add a fuzzy match on taxa names.
    if name.nil?
      return nil
    end
    name
  end

  def get_antcat_name_id_from_hash hol_hash
    Rails.logger.level = Logger::INFO

    hol_name = hol_hash['name']
    return get_antcat_name_from_string hol_name
  end

end
