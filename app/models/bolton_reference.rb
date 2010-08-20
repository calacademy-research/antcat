class BoltonReference < ActiveRecord::Base
  set_table_name 'bolton_refs'
  belongs_to :reference, :foreign_key => 'ward'

#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

  def self.import(filename, show_progress = false)
    $stderr.print "Importing #{filename}" if show_progress
    doc = Nokogiri::HTML(File.read(filename))
    ps = doc.css('p')
    ps.each do |p|
      s = p.inner_html
      $stderr.print '.' if show_progress

      s = s.gsub(/\n/, ' ').strip
      s = s.gsub(/<.+?>/, '')
      s = CGI.unescapeHTML(s)

      next unless s.length > 20

      s, date = extract_date s

      match = s.match /(\D+) ?(\d\w+)\.? ?(.+)[,.](?: \[(.+)\])?/

      unless match && match.size >= 4
        puts
        puts s
        puts match
        next
      end

      authors = match[1].strip
      year = match[2].strip
      title_and_citation = match[3].strip

      reference = BoltonReference.create! :authors => authors, :year => year, :title_and_citation => title_and_citation, :date => date
    end
    $stderr.puts if show_progress
  end

  def self.extract_date s
    parts = s.split(/ ?\[([^\]]+)\]$/)
    return s, nil unless parts.length == 2
    return parts
  end

  def self.match_all show_progress = false

    unmatched = 0
    $stderr.print "Setting up" if show_progress
    wards = Reference.all.map do |e|
      title_and_citation = remove_punctuation(e.title + e.citation)
      {:reference => e, :title_and_citation => title_and_citation, :pairs => make_pairs(title_and_citation)}
    end
    $stderr.puts if show_progress

    start = Time.now
    all_count = count
    all.each_with_index do |bolton, i|
      title_and_citation = remove_punctuation(bolton.title_and_citation)
      max_similarity = 0
      best_match = nil
      ward = wards.find do |ward|
        similarity = string_similarity(title_and_citation, ward[:pairs])
        if similarity > max_similarity
          max_similarity = similarity
          best_match = ward
        end
        similarity > 0.85
      end
      bolton.update_attribute(:ward_id, ward && ward[:reference].id)
      unmatched += 1 unless ward
      if show_progress
        elapsed = Time.now - start
        rate = ((i + 1) / elapsed)
        rate_s = sprintf("%.2f", rate) + "/sec"
        time_left = sprintf("%.0f", (count - i + 1) / rate / 60) + " mins left"
        $stderr.puts "#{i + 1}/#{all_count} (#{unmatched} unmatched) #{rate_s} #{time_left}" if show_progress
        $stderr.puts bolton if show_progress
        if ward
          $stderr.puts "Ward: " + ward[:reference].to_s if show_progress
        else
          $stderr.puts "No match: best was #{max_similarity}:\n#{best_match[:reference]}" if show_progress
          $stderr.puts "B: " + title_and_citation
          $stderr.puts "W: " + best_match[:title_and_citation]
        end
        $stderr.puts
      end
    end
    $stderr.puts if show_progress
  end

  def self.remove_punctuation s
    s.gsub(/\W/, '')
  end

  def self.make_pairs str1
    str1.downcase 
    (0..str1.length-2).collect {|i| str1[i,2]}.reject { |pair| pair.include? " "}
  end

  def self.full_string_similarity str1, str2
    string_similarity(str1, make_pairs(str2))
  end

  def self.string_similarity str1, pairs2
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

  def to_s
    "#{authors} #{year}. #{title_and_citation}."
  end
end
