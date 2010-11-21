class WardReference < ActiveRecord::Base
  belongs_to :reference

  def self.export show_progress = false
    Progress.init show_progress, count
    Progress.puts "Exporting WardReferences to References..."
    all.each do |ward_reference|
      begin
        ward_reference.export
        self.show_progress
      rescue StandardError => e
        puts
        p ward_reference
        p ward_reference.citation
        puts e
        puts e.backtrace
      end
    end
    self.show_results
  end

  def self.show_progress
    Progress.tally
    return unless Progress.processed_count % 10 == 0

    count = "#{Progress.processed_count}/#{Progress.total_count}".rjust(12)
    rate = Progress.rate.rjust(9)
    time_left = Progress.time_left.rjust(11)
    Progress.puts "#{count} #{rate} #{time_left}"
  end

  def self.show_results
    Progress.puts "#{Progress.processed_count} references in #{Progress.elapsed} #{Progress.rate}"
  end

  def export
    reference = Reference.import to_import_format
    update_attribute(:reference, reference)

    fix reference

    reference
  end

  def fix reference
    if citation == 'Memorias de la Real Sociedad Española de Historia Natural, Tomo del Cincuentenario:424-436.'
      reference.journal = Journal.import('Memorias de la Real Sociedad Española de Historia Natural')
      reference.series_volume_issue = 'Tomo del Cincuentenario'
      reference.pagination = '424-436'
      reference.save!
      Journal.find_by_name('Memorias de la Real Sociedad Española de Historia Natural, Tomo del').destroy
    end
  end

  def to_import_format
    data = {:id => id, :class => self.class.to_s}

    if authors
      author_data = AuthorParser.parse(authors.dup)
      data[:author_names] = author_data[:names]
      data[:author_names_suffix] = author_data[:suffix]
    end
    data.merge!(CitationParser.parse(citation) || {})
    data[:citation_year] = remove_period_from year
    data[:cite_code] = cite_code
    data[:date] = date
    parse_notes data
    data[:possess] = possess
    data[:taxonomic_notes] = taxonomic_notes
    data[:title] = remove_period_from title
    data
  end

  def parse_notes data
    return if notes.blank?
    data[:public_notes] = data[:editor_notes] = ''
    if editor_notes.present?
      data[:public_notes] = notes
      data[:editor_notes] = editor_notes
    elsif match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/)
      data[:public_notes] = match[1] || ''
      data[:editor_notes] = match[2] || ''
    end
  end

  def remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
