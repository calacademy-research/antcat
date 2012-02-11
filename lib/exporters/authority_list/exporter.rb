# coding: UTF-8
class Exporters::AuthorityList::Exporter
  def initialize show_progress = false
    Progress.init show_progress
  end

  def export directory
    File.open("#{directory}/antcat_authority_list.txt", 'w') do |file|
      write_header file
      write_rows file, sort_rows(get_rows)
    end
    Progress.show_results
  end

  def get_rows
    Taxon.all.inject([]) do |rows, taxon|
      data = get_data taxon
      rows << data if data
      rows
    end
  end

  def write_rows file, rows
    for row in rows
      write file, format(row)
    end
  end

  def write_header file
    write file, format('subfamily', 'tribe', 'genus', 'species', 'subspecies', 'status', 'senior synonym', 'fossil')
  end

  def write file, line
    file.puts line
  end

  def format *values
    values.join "\t"
  end

  def sort_rows rows
    rows.sort
  end

  def get_data taxon
    Progress.tally_and_show_progress 1000

    case taxon
    when Species
      return unless taxon.genus && taxon.genus.tribe && taxon.genus.tribe.subfamily
      [taxon.subfamily.name, taxon.genus.tribe.name, taxon.genus.name, taxon.name, '', taxon.status,
        get_senior_synonym_of(taxon), taxon.fossil? ? 'fossil' : '']

    when Subspecies
      return unless taxon.species && taxon.species.genus && taxon.species.genus.tribe && taxon.species.genus.tribe.subfamily
      [taxon.species.genus.subfamily.name, taxon.species.genus.tribe.name, taxon.species.genus.name,
        taxon.species.name, taxon.name, taxon.status, get_senior_synonym_of(taxon), taxon.fossil? ? 'fossil' : '']
    else nil
    end
  end

  def get_senior_synonym_of taxon
    return '' unless taxon.synonym?
    taxon.synonym_of.try(:full_name) || ''
  end

end
