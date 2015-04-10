class Importers::Hol::HolAuthorMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    @journal_name_string_map ={}

    Rails.logger.level = Logger::INFO


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
    Rails.logger.level = Logger::INFO

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
      if mapped_name.nil?
        return nil
      end
      author_name = find_author mapped_name
      unless author_name.nil?
        # puts " Found alternate full name spelling: " + author_name['name']
      end
    end

    if author_name.nil?
      #puts "failed to get author, trying search: " +full_name + " tnuid: " + details_hash['tnuid'].to_s
      #print_char "A"
      return author_search_matcher full_name
    end
    #print_char "a"
    author_name.author_id
  end

  def find_author name
    AuthorName.find_by_name name
  end

  #note that each reference can have multiple authors; check all
  def author_search_matcher hol_string

    references = reference_search hol_string
    if references.nil?
      return nil
    end
    references.each do |reference|
      if reference.author_names.nil? || reference.author_names.length == 0
        next
      end
      reference_author_names = reference.author_names
      reference_author_names.each do |reference_author|
        cur_author_name = reference_author
        @cur_string = cur_author_name.name
        @cur_id = reference_author.author_id
        check_and_swap_reference
      end
    end
    return filter_result @author_full_name_string_map
  end


  def author_search search_string
    # This is not too useful; it only returns on perfect matches.
    # params={filter: :no_missing_references,
    #         is_author_string: true,
    #         author_names: search_string}


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
