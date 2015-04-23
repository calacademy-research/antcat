class Importers::Hol::HolReferenceMatcher < Importers::Hol::BaseUtils
  def get_reference hol_details, hol_hash, journal_matcher
    @journal_matcher = journal_matcher
    @antcat_author_id = hol_details['antcat_author_id']
    @antcat_journal_id = hol_details['antcat_journal_id']
    @hol_year = hol_details['year']
    @hol_start_page = hol_details['start_page']
    @hol_end_page = hol_details['end_page']


    if @antcat_author_id.nil? or @antcat_journal_id.nil?
      return nil
    end
    hol_title = extract hol_hash, ["orig_desc", "title"]
    if hol_title.nil?
      return nil
    end


    return reference_title_matcher hol_title
  end

  def initialize
    super
    @reference_title_name_string_map ={}
  end

  def reference_title_matcher hol_string
    Rails.logger.level = Logger::INFO
    Rails.logger.debug "@references: failed to find journal name in antcat: " +hol_string
    references = reference_search hol_string
    if references.nil?
    #  puts "No references"
      return nil
    end
    references.each do |reference|
      if reference.title.nil?
   #     puts ("***** reference has no title?")
        next
      end
      # Many references lack a journal ID altogether
      # since HOL has one, we might be able to add it if everything else makes sense.
      unless  reference.journal.nil?
        if reference.journal_id != @antcat_journal_id
            #   puts "\nFailed journal match"
          #     dump_reference_info reference
          next
        end
      end
      if reference.reference_author_names.length==0
  #         puts ("**** no authors to match")

        next
      end
      if reference.reference_author_names.first.author_name.author_id != @antcat_author_id
           # puts ("Failed author match: " +
           #          reference.reference_author_names.first.author_name.name.to_s +˜                                       ˜
           #          " " +
           #          AuthorName.find(@antcat_author_id).name)
        next
      end

      if reference.year != @hol_year
   #       puts ("Failed year match")
        next
      end
      page_hash = get_page_from_string reference.pagination
      start_page = page_hash[:start_page]
      end_page = page_hash[:end_page]
      unless page_hash.nil?
        unless page_in_range  @hol_start_page, @hol_end_page,  start_page,end_page
          next
        end
      end



      @cur_string = reference.title
      @cur_id = reference.id
      @cur = reference
      check_and_swap_reference
    end
    # if @candidate_antcat_string.nil?
    #   puts "No matches for this title: " + hol_string
    # else
    #   puts "Matched reference:" + hol_string
    # end


    filter_result @reference_title_name_string_map
  end

  # TODO: log these for researchers to do something interesting with.
  # TODO showing this for every reference; perhaps we should only show them when we don't match on any?
  def dump_reference_info reference
    if reference.journal_id.nil?
      puts "Reference has no journal id: " + reference.id.to_s
    else
      ref_journal_name = Journal.find(reference.journal_id).name
      puts ("   ref journal: " + ref_journal_name)
    end

    matched_hol_journal_name = Journal.find(@antcat_journal_id).name
    puts ("   matched antcat journal name: " + matched_hol_journal_name)

    original_hol_journal_name = @journal_matcher.get_original_hol_journal matched_hol_journal_name


    if original_hol_journal_name.nil?
      puts ("   original hol journal name (perfect match): " + matched_hol_journal_name)
    else
      # if this is nil, it's because we have a 1:1 string mapping between antcat and hol's understanging of the journal name
      puts ("   original hol journal name: " + original_hol_journal_name)
    end
  end

end

