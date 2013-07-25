# coding: UTF-8
class Exporters::TaxonList::Exporter
  def initialize show_progress = false
    Progress.init show_progress
  end

  def export directory = 'data/output'
    File.open "#{directory}/antcat_taxon_list.txt", 'w' do |file|
      write_header file
      write_rows file, get_rows
    end
    Progress.show_results
  end

  def get_rows
    Taxon.all.inject [] do |rows, taxon|
      data = get_data taxon
      rows << data if data
      rows
    end
  end

  def write_rows file, rows
    for row in rows
      write file, join(row)
    end
  end

  def write_header file
    write file, join('name', 'authors', 'year', 'valid')
  end

  def write file, line
    file.puts line
  end

  def join *values
    values.join "\t"
  end

  def get_data taxon
    Progress.tally_and_show_progress 1000
    case taxon
    when Species then [taxon.name.to_s, 1840, 'Shuckard', 'valid']
    end
  end

end
