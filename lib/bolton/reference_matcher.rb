class Bolton::ReferenceMatcher

  def initialize show_progress = false
    Progress.init show_progress, Bolton::Reference.count
    @unmatched_count = 0
  end

  def find_matches_for_all
    Bolton::Match.delete_all
    Bolton::Reference.all[0..100].each_with_index do |bolton, i|
      find_matches_for bolton
      show_progress
    end
    show_results
  end

  def find_matches_for bolton
    return if bolton.reference_type == 'UnknownReference'
    wards = ward_references_for bolton
    bolton_last_name = bolton.principal_author_last_name
    wards.each do |ward|
      next unless bolton_last_name == ward.author_names.first.last_name
      Bolton::Match.create! :bolton_reference_id => bolton.id, :reference_id => ward.id, :confidence => 1
      #next unless reference.author_names.first.last_name == bolton_last_name
      #next unless reference.type == bolton.reference_type
      #next unless reference.matches? bolton
    end
  end

  private
  def ward_references_for bolton
    ::Reference.with_principal_author_last_name_like bolton.principal_author_last_name
  end

  def show_progress
    Progress.tally
    return unless Progress.processed_count % 100 == 0
    Progress.puts "#{Progress.progress_message} #{Progress.count @unmatched_count, Progress.processed_count, 'unmatched'}"
  end

  def show_results
    Progress.puts "#{Progress.results_message} #{Progress.count @unmatched_count, Progress.processed_count, 'unmatched'}"
  end

end
