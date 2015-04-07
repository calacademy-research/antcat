require 'fuzzystringmatch'


class Importers::Hol::JournalMatcher < Importers::Hol::BaseUtils

  def initialize
    Rails.logger.level = Logger::INFO
    @journal_name_string_map ={}
  end

  def get_antcat_journal_id hol_journal_name


    if (@journal_name_string_map)
      if hol_journal_name.nil?
        return nil
      end
      journal = Journal.find_by_name hol_journal_name
      if journal.nil? && @journal_name_string_map.has_key?(hol_journal_name)
        mapped_name = @journal_name_string_map[hol_journal_name]
        Rails.logger.debug "Hey, we know this one. Here it is: " + mapped_name
        return Journal.find_by_name(mapped_name).id
      end
      if journal.nil?
        return journal_search_matcher hol_journal_name
      end
      journal.id
    end
  end

  def journal_search_matcher hol_journal_name
    Rails.logger.debug "failed to find journal name in antcat: " +hol_journal_name
    references = reference_search hol_journal_name
    journal_id = nil
    candidate_antcat_journal_string = nil
    journal_distance = 0
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    if (references.length == 0)
      Rails.logger.debug "No references found."
      return nil
    end
    references.each do |reference|
      if reference.journal.nil?
        next
      end
      cur_journal_name = reference.journal.name
      Rails.logger.debug "found a:" + cur_journal_name.to_s + " "
      if journal_id.nil?
        journal_id = reference.journal.id
        candidate_antcat_journal_string = cur_journal_name
        journal_distance = jarow.getDistance(cur_journal_name, hol_journal_name)
        Rails.logger.debug " first example:" + journal_distance.to_s
      else
        if journal_id == reference.journal.id
          Rails.logger.debug "these are the same, skipping"
          next
        end
        new_distance = jarow.getDistance(cur_journal_name, hol_journal_name)
        if new_distance > journal_distance
          journal_id = reference.journal.id
          candidate_antcat_journal_string = cur_journal_name
          journal_distance = new_distance
          Rails.logger.debug " I like this better: " + new_distance.to_s
        else
          Rails.logger.debug " Kept the old one: " + new_distance.to_s
        end
      end
    end
    if journal_distance > 0.75
      Rails.logger.debug ("The winner is: " + candidate_antcat_journal_string)
      @journal_name_string_map[hol_journal_name] = candidate_antcat_journal_string
      return journal_id
    else
      Rails.logger.debug ("This just isn't close enough. Discarding.")
      return nil
    end
  end

  def reference_search search_string
    params={filter: :no_missing_references,
            fulltext: search_string}

    Reference.perform_search params

  end
end
