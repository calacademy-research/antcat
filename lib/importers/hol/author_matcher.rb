require 'fuzzystringmatch'

class Importers::Hol::AuthorMatcher < Importers::Hol::BaseUtils

  def initialize

    def initialize
      Rails.logger.level = Logger::INFO
      @journal_name_string_map ={}
    end

    # Map from hol name to antcat name
    @author_last_name_string_map={'Jaegerskioeld' => 'Jägerskiöld'}
    # @author_full_name_string_map={'Brown, W. L.' => 'Brown, W. L., Jr.',
    #                               'McAreavey, J. J.' => 'McAreavey, J.',
    #                               'Peng, J.-W.' => 'Peng, J.',
    #                               'Watkins, J. F.' => 'Watkins, J. F., II',
    #                               'Ihering, H. von' => 'Ihering, H.',
    #                               'Cole, A. C.' => 'Cole, A. C., Jr.',
    #                               'Olivier, A.-G.' => 'Olivier, A. G.',
    #                               'Förster, A.' => 'Forster, J. A.',
    #                               'Tarbinsky, Yu. S.' => 'Tarbinsky, Y. S.',
    #                               'Motschoulsky, V. de.' => 'Motschoulsky, V. de',
    #                               'Almeida, A. J.' => 'Almeida Filho, A. J. de',
    #                               '' => '',
    #                               '' => '',
    #                               '' => ''}

    @author_last_name_string_map={'Jaegerskioeld' => 'Jägerskiöld'}
    @author_full_name_string_map={
                                  '' => '',
                                  '' => '',
                                  '' => ''}
  end

  #
  # Tries to match against a string literal in the database, then the string map,

  #
  def get_antcat_author_id details_hash
    last_name = extract details_hash, ["orig_desc", "author_extended", 0, "last_name"]
    if last_name.nil?
      print_char "L"
      #puts (" Failed to extract last name for id: " + details_hash['tnuid'].to_s)
      return nil
    end
    initials = extract details_hash, ["orig_desc", "author_extended", 0, "initials"]

    author_name = find_author make_full_name last_name, initials
    if author_name.nil? && @author_last_name_string_map.has_key?(last_name)
      mapped_name = @author_last_name_string_map[last_name]
      author_name = find_author make_full_name mapped_name, initials
      unless author_name.nil?
        # puts " Found alternate spelling: " + author_name['name']
      end
    end

    full_name = make_full_name last_name, initials
    if author_name.nil? && @author_full_name_string_map.has_key?(full_name)
      mapped_name = @author_full_name_string_map[full_name]
      author_name = find_author mapped_name
      unless author_name.nil?
        # puts " Found alternate full name spelling: " + author_name['name']
      end
    end

    if author_name.nil?
      puts "failed to get author, trying search: " +full_name + " tnuid: " + details_hash['tnuid'].to_s
      #print_char "A"
      return author_search_matcher full_name
    end
    print_char "a"
    author_name.author_id
  end

  def find_author name
    AuthorName.find_by_name name
  end

  #note that each reference can have multiple authors; check all
  def author_search_matcher hol_author_full_name
    references = author_search hol_author_full_name
    author_id = nil
    candidate_antcat_author_string = nil
    author_distance = 0

    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    if references.length == 0
      Rails.logger.debug "No references found."
      return nil
    end
    references.each do |reference|
      if reference.journal.nil?
        next
      end
      reference_author_names = reference.author_names
      reference_author_names.each do |reference_author|
        cur_author_name = reference_author
        cur_author_name_string = cur_author_name.name
        cur_author_id = reference_author.author_id
       # Rails.logger.debug "found author:" + cur_author_name_string + " "
        if author_id.nil?
          author_id = cur_author_id
          candidate_antcat_author_string = cur_author_name_string
          author_distance = jarow.getDistance(candidate_antcat_author_string,hol_author_full_name)
          Rails.logger.debug " first example:" + cur_author_name_string+ " " + author_distance.to_s
        else
          if cur_author_id == author_id
           # Rails.logger.debug "these are the same, skipping"
            next
          end
          new_distance = jarow.getDistance(cur_author_name_string, hol_author_full_name)
          if new_distance > author_distance
            author_id = cur_author_id
            candidate_antcat_author_string = cur_author_name_string
            author_distance = new_distance
            Rails.logger.debug " I like this better: " + candidate_antcat_author_string+ " " + new_distance.to_s
          else
            Rails.logger.debug " Kept the old one: " + cur_author_name_string+ " " + new_distance.to_s
          end
        end
      end
    end
    if author_distance > 0.75
      Rails.logger.debug ("The winner is: " + candidate_antcat_author_string)
      @author_full_name_string_map[hol_author_full_name] = candidate_antcat_author_string
      return author_id
    else
      Rails.logger.warning (hol_author_full_name + " just isn't close enough to "+candidate_antcat_author_string+". Discarding.")
      return nil
    end
  end




  def author_search search_string
    # This is not too useful; it only returns on perfect matches.
    # params={filter: :no_missing_references,
    #         is_author_string: true,
    #         author_names: search_string}
    params={filter: :no_missing_references,
            fulltext: search_string}
    Reference.perform_search params

  end

  def make_full_name last_name, initials
    name = nil
    if (initials.nil?)
      name = last_name
    else
      name = last_name + ", " + initials
    end
    name
  end

end
