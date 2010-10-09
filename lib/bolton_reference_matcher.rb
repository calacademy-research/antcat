class BoltonReferenceMatcher
  SUFFICIENT_SIMILARITY = 0.75

  def initialize show_progress = false
    Progress.init show_progress
    @all_count = BoltonReference.count
    @unmatched_count = @suspect_count = 0
    make_ward_index
    @start = Time.now
  end

  def match_all
    BoltonReference.all.each_with_index do |bolton, i|
      bolton.update_attributes :ward_reference => match(bolton, i), :suspect => suspect?
    end
    show_results
  end

  def suspect?
    @suspect
  end

  def match bolton, i = 0
    @bolton = bolton
    @title_and_citation = normalize(bolton.title_and_citation)
    @max_similarity = 0
    @best_match = nil
    @found_ward = nil
    @suspect = false

    @wards = @ward_index[@bolton.authors.downcase[0,2]]
    if @wards
      @found_ward = match_similarity || match_suffix || match_author_year_and_digits
    end

    if @found_ward
      ward = @found_ward[:reference]
      @suspect ||= ward.numeric_year != @bolton.year.to_i
      @suspect ||= normalize(ward.authors) != normalize(@bolton.authors)
    else
      @unmatched_count += 1
    end

    @suspect_count += 1 if @suspect

    show_progress i

    @found_ward && @found_ward[:reference]
  end

  private
  def match_similarity
    @wards.each do |ward|
      similarity = string_similarity(@title_and_citation, ward[:pairs])
      if similarity > @max_similarity
        @max_similarity = similarity
        @best_match = ward
      end
    end
    @max_similarity >= SUFFICIENT_SIMILARITY ? @best_match : nil
  end

  SUFFICIENT_MATCHING_SUFFIX_LENGTH = 10

  def match_suffix
    @wards.find do |ward|
      matching_suffix_length = 0
      bolton_string = @title_and_citation
      ward_string = ward[:title_and_citation]
      bolton_index = bolton_string.length - 1
      ward_index = ward_string.length - 1
      loop do
        break if bolton_index < 0
        break if ward_index < 0
        break if bolton_string[bolton_index] != ward_string[ward_index]
        matching_suffix_length += 1
        if matching_suffix_length >= SUFFICIENT_MATCHING_SUFFIX_LENGTH
          return ward
        end
        bolton_index -= 1
        ward_index -= 1
      end
    end
    nil
  end

  SUFFICIENT_MATCHING_DIGITS_LENGTH = 4

  def match_author_year_and_digits
    @wards.find do |ward|
      next unless ward[:reference].authors == @bolton.authors
      next unless ward[:reference].numeric_year == @bolton.year.to_i
      bolton_digits = @title_and_citation.gsub(/\D/, '')
      ward_digits = ward[:title_and_citation].gsub(/\D/, '')
      next unless bolton_digits == ward_digits
      next unless bolton_digits.length >= SUFFICIENT_MATCHING_DIGITS_LENGTH
      @suspect = true
      true
    end
  end

  def make_ward_index
    Progress.print "Setting up..."
    @ward_index = Reference.all.inject({}) do |index, reference|
      s = remove_parenthesized_taxon_names(reference.title + reference.citation)
      s = normalize s
      entry = {
        :reference => reference,
        :title_and_citation => s,
        :pairs => make_pairs(s)
      }
      key = reference.authors.downcase[0, 2]
      index[key] ||= []
      index[key] << entry
      index
    end
    Progress.puts 'done'
  end

  def remove_parenthesized_taxon_names s
    match = s.match(/ \(.+?\)/)
    return s unless match
    b = match.begin(0)
    e = match.end(0) - 1
    possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
    is_wards_taxon_names = possible_taxon_names.any? do |possible_taxon_name|
      ['Formicidae', 'Hymenoptera'].include? possible_taxon_name
    end
    if is_wards_taxon_names
      s[b..e] = ''
    end
    s
  end

  def normalize s
    s = s.gsub(/\(No\. (\d+)\)/, '\1') # "(No. 1)" => "(1)"
    s = remove_punctuation s
    s
  end

  def remove_punctuation s
    s.gsub(/\W/, '')
  end

  def make_pairs str1
    str1.downcase 
    (0..str1.length-2).collect {|i| str1[i,2]}.reject { |pair| pair.include? " "}
  end

  def string_similarity str1, pairs2
    pairs1 = make_pairs str1
    pairs2 = pairs2.clone
    union = pairs1.size + pairs2.size 
    intersection = 0 
    pairs1.each do |p1| 
      0.upto(pairs2.size-1) do |i| 
        if p1 == pairs2[i] 
          intersection += 1 
          pairs2.slice!(i) 
          break 
        end 
      end 
    end 
    (2.0 * intersection) / union
  end

  def show_progress i
    return unless !@found_ward || @suspect

    elapsed = Time.now - @start
    rate = ((i + 1) / elapsed)
    rate_s = sprintf("%.2f", rate) + "/sec"
    time_left = sprintf("%.0f", (@all_count - i + 1) / rate / 60) + " mins left"

    Progress.puts "******************** No match" unless @found_ward
    Progress.puts "???????????????????? Suspect" if @suspect
    Progress.puts @bolton

    if @found_ward
      Progress.puts "WARD: "
      Progress.puts @found_ward[:reference].to_s
    else
      Progress.puts "Best was #{@max_similarity}:\n#{@best_match[:reference]}" if @best_match
    end
    Progress.puts "#{i + 1}/#{@all_count} (#{@unmatched_count} unmatched, #{@suspect_count} suspect) #{rate_s} #{time_left}"
    Progress.puts
  end

  def show_results
    Progress.puts
    elapsed = Time.now - @start
    elapsed = sprintf("%.0f mins", elapsed / 60)
    unmatched_percent = sprintf("%.0f%%", @unmatched_count * 100.0 / @all_count)
    suspect_percent = sprintf("%.0f%%", @suspect_count * 100.0 / @all_count)
    Progress.puts "#{elapsed}. #{@all_count} processed, #{@unmatched_count} unmatched (#{unmatched_percent}), #{@suspect_count} suspect (#{suspect_percent})"
  end

end
