class Importers::Hol::HolNameMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
    @name_string_map ={}
  end

  def get_original_hol_name value
    @name_string_map.key(value)
  end

  def get_antcat_name_id hol_deatils, hol_hash
    Rails.logger.level = Logger::INFO


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
    name.id

  end

end
