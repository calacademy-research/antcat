class Bolton::ReferenceMatcher

  def initialize show_progress = false
    Progress.init show_progress, Bolton::Reference.count
    @unmatched_count = 0
  end

  def match_all
    Bolton::Reference.all.each_with_index do |bolton, i|
      match = find_match bolton
      bolton.update_attribute :ward_reference_id, match && match.id
      @unmatched_count += 1 unless match
      show_progress
    end
    show_results
  end

  def find_match bolton
    bolton_last_name = last_name(bolton.authors)
    ::Reference.possible_matches(bolton_last_name, bolton.reference_type).find do |reference|
      next unless reference.author_names.first.last_name == bolton_last_name
      next unless reference.type == bolton.reference_type
      next unless reference.matches? bolton
      true
    end
  end

  private
  def show_progress
    Progress.tally
    return unless Progress.processed_count % 100 == 0
    Progress.puts "#{Progress.progress_message} #{Progress.count @unmatched_count, Progress.processed_count, 'unmatched'}"
  end

  def show_results
    Progress.puts "#{Progress.results_message} #{Progress.count @unmatched_count, Progress.processed_count, 'unmatched'}"
  end

  def last_name string
    string.split(',').first
  end

end
