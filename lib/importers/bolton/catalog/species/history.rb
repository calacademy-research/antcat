# coding: UTF-8
class Importers::Bolton::Catalog::Species::History
  attr_reader :status, :epithet

  def initialize history
    @history = history
    @index = 0
    @status = 'valid'
    determine_status
  end

  def determine_status
    while get_next_item
      next if check_synonym
      return if check_first_available_replacement
      check_homonym or
      check_having_subspecies or
      check_revival_from_synonymy or
      check_unavailable_name or
      check_unidentifiable or
      check_nomen_nudum or
      check_excluded
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
        if item[:matched_text] =~ /First replacement name: <i>(\w+)<\/i>/
          @epithet = $1
          get_next_item
        end
        @status = 'homonym'
        return true
      end
    elsif text_matches? @item, /homonym/i
      @status = 'homonym'
      return true
    end
  end

  def check_having_subspecies
    if @item[:subspecies]
      @status = 'valid'
      return true
    end
  end

  def check_synonym
    if @item[:matched_text] =~ /Unnecessary replacement.*?hence junior synonym of <i>(\w+)<\/i>/
      @status = 'synonym'
      @epithet = $1
      return true
    elsif @item[:synonym_ofs]
      @status = 'synonym'
      @epithet = @item[:synonym_ofs].first[:species_epithet]
      return true
    end
  end

  def check_revival_from_synonymy
    if @item[:revived_from_synonymy] ||
       @item[:raised_to_species].try(:[], :revived_from_synonymy)
      @status = 'valid'
      return true
    end
  end

  def check_unidentifiable
    if @item[:unidentifiable] || text_matches?(@item, /unidentifiable/i)
      @status = 'unidentifiable'
      return true
    end
  end

  def check_excluded
    if text_matches? @item, /Excluded from Formicidae/i
      @status = 'unidentifiable'
      return true
    end
  end

  def check_first_available_replacement
    if text_matches? @item, /[fF]irst available replacement/
      @status = 'valid'
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

  def check_excluded
    if text_matches? @item, /Excluded from Formicidae/i
      @status = 'excluded'
      return true
    end
  end

  def text_matches? item, regexp
    @matches = nil
    return unless text = item[:matched_text]
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
