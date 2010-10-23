class WardReference < ActiveRecord::Base
  belongs_to :reference

  def self.export show_progress = false
    Progress.init show_progress
    all.each do |ward_reference|
      ward_reference.export
      Progress.print '.'
    end
    Progress.puts
  end

  def export
    reference = Reference.import to_import_format
    update_attribute(:reference, reference)
    reference
  end

  def to_import_format
    parser = ReferenceParser.new
    data = {:id => id, :class => self.class.to_s}
    data[:authors] = parser.parse_authors authors
    data.merge! parser.parse_citation(citation) || {}
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
    if match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/)
      data[:public_notes] = match[1] || ''
      data[:editor_notes] = match[2] || ''
    end
  end

  def remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
