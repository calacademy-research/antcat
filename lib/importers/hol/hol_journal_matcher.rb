require 'fuzzystringmatch'


class Importers::Hol::HolJournalMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
    @journal_name_string_map ={}
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
