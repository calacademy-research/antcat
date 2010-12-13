class Ward::Reference < ActiveRecord::Base
  belongs_to :reference
  set_table_name :ward_references

  def self.export show_progress = false
    Progress.init show_progress, count
    Progress.puts "Exporting Ward::References to References..."
    all.each do |ward_reference|
      begin
        ward_reference.export
        Progress.tally_and_show_progress 10
      rescue StandardError => e
        puts
        p ward_reference
        p ward_reference.citation
        puts e
        puts e.backtrace
      end
    end
    Progress.show_results
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
      author_data = Ward::AuthorParser.parse(authors.dup)
      data[:author_names] = author_data[:names]
      data[:author_names_suffix] = author_data[:suffix]
    end
    data.merge!(Ward::CitationParser.parse(citation) || {})
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
