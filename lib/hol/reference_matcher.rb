class Hol::ReferenceMatcher

  def initialize
    @bibliography = Hol::Bibliography.new
  end

  def match target_reference
    result = {}
    author_name = target_reference.author_names.first.last_name
    references = candidates_for target_reference
    unless references.present?
      result[:status] = :no_entries_for_author
    else
      references.each do |reference|
        if target_reference.year == reference[:year]
          break if @bibliography.match_series_volume_issue_pagination target_reference, reference, result
          break if @bibliography.match_title target_reference, reference, result
        end
      end
    end
    result
  end

  def candidates_for target
    if target != @target
      @target = target
      @candidates = read_references target
    end
    @candidates || []
  end

  def read_references target
    @bibliography.read_references target.principal_author_last_name
  end

end
