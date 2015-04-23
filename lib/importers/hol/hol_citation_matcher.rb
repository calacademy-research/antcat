class Importers::Hol::HolCitationMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
  end


  # Hol details is model we're populating.
  # precondition: we're identified the reference
  #
  def get_antcat_citation_id reference, hol_details, details_hash, diags = false
    Rails.logger.level = Logger::INFO

    if reference.nil?
      return nil
    end
    hol_start_page = hol_details['start_page']
    hol_end_page = hol_details['end_page']
    # Iterate over all citations with this reference, and see if our citation page range fits inside of
    # it. If there are multiple matches...?
    citation = nil
    Citation.all.where(:reference_id == reference).each do |cur_citation|
      pages = cur_citation.pages
      if pages.nil?
        next
      end
      page_hash = get_page_from_string pages
      start_page = page_hash[:start_page]
      end_page = page_hash[:end_page]
      if page_in_range  hol_start_page, hol_end_page, start_page,end_page
        if citation.nil?
          citation = cur_citation
        else
          #
          # No ambiguity tolerated at this point.
          #
          puts "\nWe have multiple matching citations:" +
                   cur_citation.pages +
                   " and " + citation.pages + " id:" +
                   cur_citation.id.to_s + " & " +
                   citation.id.to_s
          return nil
        end

      else
        if diags
          print "  Page out of range for this citation - cur citation pages: " +
                    pages +
                    " " +
                    "which hash as:"

          if page_hash.nil?
            print "nil"
          else
            print page_hash[:start_page].to_s +
                      "-" +
                      page_hash[:end_page].to_s
          end
          puts " compared to: " +
                   hol_start_page.to_s +
                   "-" +
                   hol_end_page.to_s +
                   " citation id: " +
                   cur_citation.id.to_s
        end
        next
      end


    end
    citation


  end
end


