class Exporters::TaxonList::Exporter
  def export directory = 'data/output'
    File.open "#{directory}/antcat_taxon_list.txt", 'w' do |file|
      write_rows file, get_rows
    end
  end

  private
    def get_rows
      Taxon.find_by_sql <<-SQL.squish
        SELECT name, year, COUNT(*) count FROM taxa join protonyms ON protonym_id = protonyms.id
        join citations ON authorship_id = citations.id join `references`
        ON reference_id = `references`.id join reference_author_names ran ON
        ran.reference_id = references.id and position = 1 join author_names an
        ON ran.author_name_id = an.id WHERE taxa.type = 'Species' AND status = 'valid'
        OR status = 'synonym' OR status = 'homonym' GROUP BY name, year ORDER BY name, year
      SQL
    end

    def write_rows file, rows
      rows.each do |row|
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
