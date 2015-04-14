class Importers::Hol::HolCitationMatcher < Importers::Hol::BaseUtils

  def initialize
    super
    Rails.logger.level = Logger::INFO
  end


  # Hol details is model we're populating.
  # precondition: we're identified the reference
  #
  def get_antcat_citation_id reference, hol_details, details_hash
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
      if page_in_range page_hash, hol_start_page, hol_end_page
        unless citation.nil?
          puts "We have multiple matching citations!"
        end
        citation = cur_citation
      else
        puts "Page out of range for this citation"
        next
      end


    end
    citation


  end
end


