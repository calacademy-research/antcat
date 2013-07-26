# coding: UTF-8
class Exporters::TaxonList::Exporter
  def export directory = 'data/output'
    File.open "#{directory}/antcat_taxon_list.txt", 'w' do |file|
      write_rows file, get_rows
    end
  end

  def get_rows
    Taxon.find_by_sql %{select name, year, count(*) count from taxa join protonyms on protonym_id = protonyms.id join citations on authorship_id = citations.id join `references` on reference_id = `references`.id join reference_author_names ran on ran.reference_id = references.id and position = 1 join author_names an on ran.author_name_id = an.id where taxa.type = 'Species' and status = 'valid' or status = 'synonym' or status = 'homonym' group by name, year order by name, year}
  end

  def write_rows file, rows
    for row in rows
      write file, join(row['name'], row['year'], row['count'])
    end
  end

  def write file, line
    file.puts line
  end

  def join *values
    values.join "\t"
  end

end
