# coding: UTF-8
class Importers::Bolton::Catalog::Species::History
  attr_reader :status, :epithets, :taxon_subclass

  def initialize history
    @history = history
    @index = 0
    @status = 'valid'
    analyze
  end

  def analyze
    while get_next_item
      check_first_available_replacement or
      check_revival_from_synonymy or
      check_raised_to_species or
      check_species or
      check_subspecies or
      check_synonym or
      check_homonym or
      check_unavailable_name or
      check_unidentifiable or
      check_nomen_nudum or
      check_excluded_from_formicidae
    end
  end

  def check_first_available_replacement
    return false if text_matches? 'oldest synonym and hence first available replacement name'
    if text_matches?(/(First|hence first) available replacement/) ||
       text_matches?(/Replacement name for/)
      @status = 'valid'
      @taxon_subclass = Species
      skip_rest_of_history
      return true
    end
  end

  def check_revival_from_synonymy
    if @item[:revived_from_synonymy] || @item[:revived_status_as_species] || text_matches?(/revived from synonym/i)
      @status = 'valid'
      if @item[:revived_from_synonymy] && @item[:revived_from_synonymy][:subspecies_of]
        @taxon_subclass = Subspecies
      else
        @taxon_subclass = Species
      end
      return true
    end
  end

  def check_raised_to_species
    if @item[:raised_to_species] or
       @item[:matched_text] =~ /Raised to species/i
      @status = 'valid'
      @taxon_subclass = Species
      return true
    end
  end

  def check_species
    if @item[:status_as_species] || @item[:subspecies]
      @status = 'valid'
      @taxon_subclass = Species
      return true
    end
  end

  def check_subspecies
    if @item[:currently_subspecies_of] or text_matches? /currently subspecies of/i
      @taxon_subclass = Subspecies
      @status = 'valid'
      return true
    end
  end

  def check_homonym
    if @item[:homonym_of]
      if @item[:homonym_of][:unresolved]
        skip_rest_of_history
        @status = 'unresolved homonym'
        return true
      else
        item = peek_next_item
        if item && item[:matched_text] =~ /First replacement name: <i>(\w+)<\/i>/
          @epithets = [$1]
          get_next_item
        end
        @status = 'homonym'
        return true
      end

    elsif text_matches?('Unresolved junior primary homonym')
      skip_rest_of_history
      @status = 'unresolved homonym'
      return true

    elsif @item[:matched_text] =~ /\bhomonym\b/i
      @status = 'homonym'
      return true

    end
  end

  def check_synonym
    if @item[:matched_text] =~ /Unnecessary replacement.*?hence junior synonym of <i>(\w+)<\/i>/
      @status = 'synonym'
      @epithets = [$1]
      return true
    elsif @item[:synonym_ofs]
      @status = 'synonym'
      @epithets = @item[:synonym_ofs].map {|e| e[:species_epithet]}
      return true
    end
  end

  def check_unidentifiable
    if @item[:unidentifiable] || text_matches?(/unidentifiable/i)
      @status = 'unidentifiable'
      return true
    end
  end

  def check_unavailable_name
    if @item[:unavailable_name]
      @status = 'unavailable'
      return true
    end
  end

  def check_nomen_nudum
    if @item[:nomen_nudum]
      @status = 'nomen nudum'
      return true
    end
  end

  def check_excluded_from_formicidae
    if text_matches? /Excluded from Formicidae/i
      @status = 'excluded from Formicidae'
      return true
    end
  end

  ############
  def text_matches? regexp
    @matches = nil
    return unless text = @item[:matched_text]
    @matches = text.match regexp
    @matches.present?
  end

  def get_next_item
    return unless @history.present? && @index < @history.size
    @item = @history[@index]
    @index += 1
  end

  def peek_next_item
    return unless @history.present? && @index < @history.size - 1
    @history[@index]
  end

  def skip_rest_of_history
    @index = @history.size
  end

end
